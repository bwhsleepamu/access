module ETL
  class ActigraphyMerger
    def initialize(master_file_path, output_directory, subjects = nil)
      @master_file_path = master_file_path
      @output_directory = output_directory
      @subjects = subjects
    end

    def merge_files
      subject_list = {all: [], merged: [], unmerged: [], untouched: []}
      subject_info = parse_master(@master_file_path)

      subject_list[:all] = @subjects.map(&:subject_code)

      subject_info.each do |subject_code, files|
        begin
          subject_notes = files.map { |file_info| "Actigraphy Source File: #{file_info[:file_path]} | #{file_info[:notes]}" }.join("\n")
          notes_file = File.open("#{@output_directory}/#{subject_code}_notes.txt", "w")
          notes_file.write(subject_notes)
          notes_file.close

          output_file = CSV.open("#{@output_directory}/#{subject_code}.csv", "wb")
          output_file << %w(subject_code labtime_decimal labtime_year labtime_hour labtime_min labtime_sec activity_count light_level epoch_length)
          
          LOAD_LOG.info "\n######## #{subject_code} ########\n"

          files.each do |file_info|
            validate_file file_info
            header_data = parse_file_header file_info[:file_path]

            LOAD_LOG.info "Writing file #{file_info[:file_path]}\n"

            write_file subject_code, file_info, header_data, output_file
          end
          output_file.close

          subject_list[:merged] << subject_code

        rescue Exception => ex
          output_file.close
          File.delete(output_file.path)
          subject_list[:unmerged] << subject_code
          LOAD_LOG.error "Subject #{subject_code} failed to merge: #{ex.class} | #{ex.message}"
        end
      end

      subject_list[:untouched] = subject_list[:all] - subject_list[:merged] - subject_list[:unmerged]

      LOAD_LOG.info "All (#{subject_list[:all].length}): #{subject_list[:all]}"
      LOAD_LOG.info "Untouched (#{subject_list[:untouched].length}): #{subject_list[:untouched]}"
      LOAD_LOG.info "Merged (#{subject_list[:merged].length}): #{subject_list[:merged]}"
      LOAD_LOG.info "Unmerged (#{subject_list[:unmerged].length}): #{subject_list[:unmerged]}"


      subject_list
    end

    def check_file_path(subject_code, file_info)
      parsed_awd_path = /\A\/(X|T)\/.*\/(\d+[A-Z]+[A-Z0-9]*)\/Actigraphy\/.*(\d+[A-Z]+[A-Z0-9]*)*.\.AWD\z/i.match(file_info[:file_path].strip)
      parsed_txt_path = /\A\/(X|T)\/.*\/(\d+[A-Z]+[A-Z0-9]*)\/.*\.txt\z/i.match(file_info[:file_path].strip)

      if parsed_txt_path.nil? and parsed_awd_path.nil?
        LOAD_LOG.warn "Problem with path parsing for #{subject_code}: #{file_info[:file_path]}"
      else
        path_subject_code = parsed_awd_path ? parsed_awd_path[2].capitalize.strip : parsed_txt_path[2].capitalize.strip

        if subject_code.capitalize.strip != path_subject_code
          raise ValidationError, "\nSubject codes are inconsistent for subject #{subject_code}: #{path_subject_code}"
        end
      end


    end


    def parse_file_header(file_path)
      extension = /\A.*(\.\w+)\z/i.match(file_path)

      if extension[1].downcase == ".txt"
        parse_txt_file_header(file_path)
      elsif extension[1].downcase == ".awd"
        parse_awd_file_header(file_path)
      else
        raise ValidationError, "Unknown file extension: #{extension[1]} for file path: #{file_path}"
      end
    end

    def parse_txt_file_header(file_path)
      file_data = { file_type: :txt, file_name: {}}

      f = File.open(file_path, "r")
      f_name = File.basename(f)

      file_data[:file_path] = file_path
      file_data[:file_name] = f_name
      f.readline()

      begin
        st_line = f.readline().strip
        et_line = f.readline().strip
        epoch_time_line = f.readline().strip

        st = Time.strptime(st_line, "Start: %m/%d/%y %H:%M:%S")
        et = Time.strptime(et_line, "End: %m/%d/%y %H:%M:%S")
        epoch_time = Time.strptime(epoch_time_line, "Epoch Time:  %H:%M:%S")
      rescue Exception => ex
        LOAD_LOG.info "Format wrong: #{file_path}\n#{st_line} | #{et_line} | #{epoch_time_line}"
      end

      file_data[:start_time] = Time.zone.local(st.year, st.month, st.day, st.hour, st.min, st.sec)
      file_data[:end_time] = Time.zone.local(et.year, et.month, et.day, et.hour, et.min, et.sec)
      file_data[:epoch_length] = epoch_time.min * 60 + epoch_time.sec

      file_data[:line_count] = %x{wc -l < "#{file_path}"}.to_i

      file_data
    end

    def write_file(subject_code, file_info, header_data, output_file)
      if header_data[:file_type] == :awd
        write_from_awd_file subject_code, file_info, header_data, output_file
      elsif header_data[:file_type] == :txt
        write_from_txt_file subject_code, file_info, header_data, output_file
      else
        raise StandardError, "File type error: #{header_data[:file_type]}"
      end
    end

    def write_from_awd_file(subject_code, file_info, header_data, output_file)
      # Setup location offsets
      file_header_lines = 7
      start_offset = (((file_info[:start_time] - header_data[:start_time]) / 60.0)/file_info[:epoch_length]).round
      start_line = start_offset + file_header_lines
      lines_to_read = ((((file_info[:end_time]) - file_info[:start_time]) / 60.0)/file_info[:epoch_length]).round + 1

      input_file = File.open(file_info[:file_path])
      #MY_LOG.info "Writing content for #{file_info[:file_path]} s_o: #{start_line} ltr: #{lines_to_read} el: #{start_line + lines_to_read} tl: #{header_data[:line_count]}"

      # offset file to desired start time
      start_line.times do
        input_file.readline
      end

      # Read file contents
      current_realtime = file_info[:start_time]
      lines_to_read.times do |i|
        #        MY_LOG.info "Lines read: #{i} at: #{Time.zone.now}" if i % 500 == 0
        line_data = /(\S+)\s*,\s*(\S+)/.match input_file.readline
        line_labtime = Labtime.parse(current_realtime)

        output_file << [subject_code, line_labtime.to_decimal, line_labtime.year, line_labtime.hour, line_labtime.min, line_labtime.sec, line_data[1], line_data[2], file_info[:epoch_length] * 60]

        # Increment current time by epoch length
        current_realtime += file_info[:epoch_length].minutes
      end

      current_realtime
    end

    def write_from_txt_file(subject_code, file_info, header_data, output_file)
      file_header_lines = 5
      input_file = File.open(file_info[:file_path])

      # Offset file header
      file_header_lines.times do
        input_file.readline
      end

      while (current_line = input_file.readline)
        line_info = read_txt_line(current_line)

        if line_info[:sample_time] >= file_info[:start_time]
          if line_info[:sample_time] <= file_info[:end_time]
            # Line time is in range of wanted times
            line_labtime = Labtime.parse(line_info[:sample_time])

            output_file << [subject_code, line_labtime.to_decimal, line_labtime.year, line_labtime.hour, line_labtime.min, line_labtime.sec, line_info[:activity_count], "", file_info[:epoch_length] * 60]
          else
            # Line times are out of range - no use reading more
            break
          end

        end
      end
    end

    def read_txt_line(line)
      line_info = {}
      div_line = line.split(',')
      lt = Time.strptime(div_line[0], "%m/%d/%y %H:%M:%S")

      line_info[:sample_time] = Time.zone.local(lt.year, lt.month, lt.day, lt.hour, lt.min, lt.sec)
      line_info[:activity_count] = div_line[1].to_f

      raise StandardError if lt.year < 1900 or line_info[:activity_count].blank?

      line_info
    end

    def parse_master(master_file_path)
      # Each subject has awd files
      # Each subject has subject code
      # Each file has file name, start time, end time

      subject_info = {}
      subject_code = nil

      CSV.foreach(master_file_path, :headers => true) do |row|
        #MY_LOG.info "#{row} #{row.headers}"
        #MY_LOG.info "sc: #{row.field("SUBJECT_CODE")} fp: #{row.field("FILE_PATH")}"
        begin
          if (@subjects.present? and @subjects.map(&:subject_code).include? row.field("SUBJECT_CODE")) or @subjects.nil?

            if row.field("SUBJECT_CODE").blank? or row.field("FILE_PATH").blank? or row.field("START_TIME").blank? or row.field("END_TIME").blank? or row.field("CONDITION").blank? or row.field("EPOCH_LENGTH").blank?
              raise ValidationError, "Missing fields for row in master file: #{row.field("SUBJECT_CODE")}\n sc: #{row.field("SUBJECT_CODE").blank?} or fp: #{row.field("FILE_PATH").blank?} or st: #{row.field("START_TIME").blank?} or et: #{row.field("END_TIME").blank?} or c: #{row.field("CONDITION").blank?} or el: #{row.field("EPOCH_LENGTH").blank?}"
            end

            if subject_code != row.field("SUBJECT_CODE")
              # Starting new subject - validate finished subject, set new subject code
              begin
                if subject_code.present? and subject_info.has_key?(subject_code)
                  validate_subject(subject_code, subject_info[subject_code])
                end
              rescue Exception => ex
                LOAD_LOG.error "Subject #{subject_code} failed to merge: #{ex.class} | #{ex.message}"
                subject_info.delete(subject_code)
              ensure
                subject_code = row.field("SUBJECT_CODE")
              end
            end

            unless subject_info.has_key?(subject_code)
              subject_info[subject_code] = []
            end

            file_info = {}
            file_info[:file_path] = row.field("FILE_PATH")
            Time.zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")
            st = Time.strptime(row.field("START_TIME"), "%Y-%m-%d %H:%M:%S")
            et = Time.strptime(row.field("END_TIME"), "%Y-%m-%d %H:%M:%S")
            file_info[:start_time] = Time.zone.local(st.year, st.month, st.day, st.hour, st.min, st.sec)
            file_info[:end_time] = Time.zone.local(et.year, et.month, et.day, et.hour, et.min, et.sec)
            file_info[:epoch_length] = row.field("EPOCH_LENGTH").to_i
            file_info[:condition] = row.field("CONDITION")
            file_info[:notes] = row.field("NOTES")

            utc_diff = file_info[:end_time].utc_offset - file_info[:start_time].utc_offset

            unless utc_diff == 0
              file_info[:end_time] += utc_diff.seconds
            end

            check_file_path(subject_code, file_info)

            subject_info[subject_code] << file_info
          end

        rescue Exception => ex
          subject_info.delete(row.field("SUBJECT_CODE"))
          LOAD_LOG.error "Row #{row} failed to load for #{row.field("SUBJECT_CODE")}: #{ex.class} | #{ex.message}"
        end
      end

      subject_info
    end


    ################################################
    ## Older Validation and Parsing Functions
    ################################################

    def parse_awd_file_header(file_path)
      # subject code from name
      # Date from name
      # type from name
      #MY_LOG.info "\n PARSING HEADER FOR #{file_path}"
      file_data = { file_type: :awd, file_name: {} }
      file = File.open(file_path, "r")

      name = File.basename(file)

      #regex for <subject_code>_<MMDDYY>_<T#>.AWD or opposite
      if (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)_{1,2}(\d\d\d\d\d\d)_(\D)(\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[3], :type_sequence => parsed_name[4].to_i, :date => Date.strptime(parsed_name[2], "%m%d%y")}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)_(\d\d\d\d\d\d\d\d)_(\D)(\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[3], :type_sequence => parsed_name[4].to_i, :date => Date.strptime(parsed_name[2], "%m%d%Y")}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)_{1,2}(\D)(\d)_(\d\d\d\d\d\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[2], :type_sequence => parsed_name[3].to_i, :date => Date.strptime(parsed_name[4], "%m%d%y")}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)(\d\d\d\d\d\d)(\D)(\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[3], :type_sequence => parsed_name[4].to_i, :date => Date.strptime(parsed_name[2], "%m%d%y")}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)_(\D)(\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[2], :type_sequence => parsed_name[3].to_i, :date => nil}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)(\D)(\d)\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => parsed_name[2], :type_sequence => parsed_name[3].to_i, :date => nil}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*)_.*\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => nil, :type_sequence => nil, :date => nil}
      elsif (parsed_name = /^(\d+[A-Z]+[A-Z0-9]*).*\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => nil, :type_sequence => nil, :date => nil}
      elsif (parsed_name = /.*(\d+[A-Z]+[A-Z0-9]*).*\.AWD/i.match(name))
        parsed_name_hash = {:subject_code => parsed_name[1], :type => nil, :type_sequence => nil, :date => nil}
      else
        raise ValidationError, "Cant parse file name for #{name}" if parsed_name.nil?
      end

      #MY_LOG.info "#{name} #{parsed_name} #{parsed_name[1]} #{parsed_name[2]} #{parsed_name[3]} #{parsed_name[4]} "

      file_data[:file_path] = file_path

      file_data[:file_name][:subject_code] = parsed_name_hash[:subject_code]
      file_data[:file_name][:type] = parsed_name_hash[:type]
      file_data[:file_name][:type_sequence] = parsed_name_hash[:type_sequence]
      file_data[:file_name][:date] = parsed_name_hash[:date]

      subject_type_line = file.readline().strip
      parsed_subject_type_line = /^([a-z0-9]*)(_(\D)(\d))?/i.match(subject_type_line) # regex for <subject_code>_<T#>

      file_data[:subject_code] = parsed_subject_type_line[1]
      file_data[:type] = parsed_subject_type_line[3]
      file_data[:type_sequence] = parsed_subject_type_line[4].to_i

      date_line = file.readline().strip
      time_line = file.readline().strip
      #MY_LOG.info date_line
      #MY_LOG.info time_line

      date = Time.strptime(date_line, "%d-%h-%Y")
      time = Time.strptime(time_line, "%H:%M")
      year = date.year
      year += 1900 if (year < 100 and year >= 50)
      year += 2000 if year < 50
      file_data[:start_time] = Time.zone.local(year, date.month, date.day, time.hour, time.min)
      file_data[:code_1] = file.readline().strip.to_i
      file_data[:code_2] = file.readline().strip.to_i
      file_data[:serial_number] = file.readline().strip
      file_data[:sex] = file.readline().strip

      file_data[:line_count] = %x{wc -l < "#{file_path}"}.to_i

      #LOAD_LOG.info "#{file_data[:subject_code]} #{file_data[:type]} #{file_data[:type_sequence]} #{file_data[:code_1]} #{file_data[:code_2]}"
      file_data

    end


    def validate_subject(subject_code, subject_info)
      conditions = []
      timeline = []
      subject_info.each do |file_info|
        conditions << file_info[:condition]
        timeline << file_info[:start_time]
        timeline << file_info[:end_time]
      end

      timeline.each_index do |i|
        begin
          if (i + 1) < timeline.length
            if timeline[i + 1] <= timeline[i]
              raise ValidationError, "Times are not in correct order for subject #{subject_code}.\n #{timeline[i]} is not before #{timeline[i+1]}}"
            end
          end
        end
      end

      lc = conditions.map { |x| x[0] }
      # TODO: Validate Conditions
    end

    def validate_master(master_file_path)
      master_file = CSV.open(master_file_path, 'rb', {:headers => true})

      master_file.readline
      raise ValidationError, "CSV File headers should be: #{%w(SUBJECT_CODE FILE_PATH START_TIME END_TIME EPOCH_LENGTH CONDITION NOTES)} \nare: #{master_file.headers}" unless master_file.headers == %w(SUBJECT_CODE FILE_PATH START_TIME END_TIME EPOCH_LENGTH CONDITION NOTES)
      master_file.close
    end



    def validate_file(file_info)
      file_data = parse_file_header file_info[:file_path]

      LOAD_LOG.info "File Data: #{file_data}"

      min_start_time = file_data[:start_time]
      rows_of_data = (file_data[:line_count] - 8)
      max_end_time = file_data[:start_time] + (rows_of_data * file_info[:epoch_length]).minutes

      if min_start_time.dst? and !max_end_time.dst?
        max_end_time += 1.hour
      end

      if max_end_time.dst? and !min_start_time.dst?
        max_end_time -= 1.hour
      end

      if file_info[:start_time] < min_start_time
        raise ValidationError, "File Name: #{file_info[:file_path]} | Error: Start time is out of range. | indicated start time: #{file_info[:start_time]} | minimum possible start time: #{min_start_time}\n"
      end

      if file_info[:end_time] > max_end_time
        raise ValidationError, "File Name: #{file_info[:file_path]} | Error: End time is out of range. | indicated end time: #{file_info[:end_time]} | maximum possible end time: #{max_end_time} | file start time: #{file_data[:start_time]} | lines: #{file_data[:line_count]}\n"
      end
    end

  end
end

