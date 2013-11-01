# For a given subject group (or list?) and file type, crawl the T drive, find all files that deal with a subject, and merge into Data Loading area
# BEFORE MERGE HAPPENS, ASK FOR APPROVAL!!

module ETL
  class DbfFileMerger
    def initialize(subject_list, merged_file_dir, file_name_prefix = nil, column_defs)
      @merged_file_dir = merged_file_dir
      @file_name_prefix = file_name_prefix
      @subject_list = subject_list
      @column_defs = column_defs
    end

    def merge
      successful_subjects = []
      unsuccessful_subjects = []

      merged_files = []
      @subject_list.each do |subject_code, files|
        begin
          subject = Subject.find_by_subject_code(subject_code)

          raise StandardError, "Subject has no admit date! #{subject.subject_code}" if subject.admit_date.nil?

          enhanced_files = files.map do |file_path|
            first_labtime = find_first_labtime(file_path, subject)
            filename_labtime = find_filename_labtime(file_path)

            { file_path: file_path, file_name: File.basename(file_path), first_labtime: first_labtime, filename_labtime: filename_labtime }
          end

          enhanced_files.sort! do |a, b|
            a[:first_labtime] <=> b[:first_labtime]
          end

          output_path = File.join(@merged_file_dir, "#{@file_name_prefix}#{subject.subject_code}.csv")
          LOAD_LOG.info "\n\n################################################"
          LOAD_LOG.info "Files to be merged for #{subject.subject_code} into #{output_path}\n"
          LOAD_LOG.info enhanced_files.map{|x| "#{x[:file_name]} | #{x[:first_labtime].to_short_s if x[:first_labtime]} | #{x[:filename_labtime].to_short_s if x[:filename_labtime]}"}.join("\n")
          LOAD_LOG.info "################################################"

          total_rows = 0
          source_info = []

          CSV.open(output_path, "wb") do |csv|

            enhanced_files.each_with_index do |file_info, i|
              dbf_file = ETL::DbfReader.open(file_info[:file_path])

              check_columns dbf_file

              if i < enhanced_files.length - 1
                # If not last DBF file in list, find row to read until

                next_file_start_time = enhanced_files[i + 1][:first_labtime]

                # For now, just use for logging puropse and to check how close the two times are together
                file_end_time = file_info[:filename_labtime]
                time_diff = next_file_start_time.to_decimal - file_end_time.to_decimal

                # Find last row index
                l = "#{"%04d" % next_file_start_time.hour}:#{"%02d" % next_file_start_time.min}"
                s = "%02d" % next_file_start_time.sec
                last_row_index = dbf_file.contents.index do |row|

                  #MY_LOG.info "l: #{l} s: #{s} r1: #{row[0]} r2: #{row[1]}"

                  row[0] == l and row[1] == s
                end
                raise StandardError, "last row index not found! #{next_file_start_time.to_short_s} #{file_info[:file_name]}" if last_row_index.blank?
                last_row_index -= 1
              else
                # If not last file in series
                 last_row_index = dbf_file.contents.length - 1
              end

              last_labtime = Labtime.from_s(dbf_file.contents[last_row_index][0], {year: subject.admit_date.year, sec: dbf_file.contents[last_row_index][1]})

              (0..last_row_index).each do |dbf_row_index|
                csv << dbf_file.contents[dbf_row_index]
              end

              file_rows = last_row_index + 1
              total_rows += file_rows

              file_log = "##\nfile name: #{file_info[:file_name]} \nstarting labtime: #{file_info[:first_labtime].to_short_s} \nending labtime: #{last_labtime.to_short_s} \nfile name labtime: #{file_info[:filename_labtime]} \nfirst row: 0 \nlast row: #{last_row_index} \ntotal rows: #{file_rows} \nfile path: #{file_info[:file_path]}"
              source_info << file_log

              LOAD_LOG.info file_log

            end

          end

          LOAD_LOG.info "Finished Merging - total rows #{total_rows}"

          successful_subjects << subject.subject_code
          merged_files << { subject: subject, path: output_path, total_rows: total_rows, source_info: source_info }
        rescue Exception => e

          unsuccessful_subjects << subject.subject_code
          MY_LOG.error "\n#############!!!!!\nFailed to merge file for subject #{subject_code}!\n#{e.message}\n#{e.backtrace.inspect}#############!!!!!\n\n"
          LOAD_LOG.error "\n#############!!!!!\nFailed to merge file for subject #{subject_code}!\n#{e.message}\n#{e.backtrace.inspect}#############!!!!!\n\n"

        end

      end

      summary = "\n################################\nFinished Merging all Subjects!\nsuccessful: ( #{successful_subjects.length}) #{successful_subjects}\nunsuccessful: ( #{unsuccessful_subjects.length}) #{unsuccessful_subjects}\n################################\n\n\n"
      MY_LOG.info summary
      LOAD_LOG.info summary


      merged_files
    end

    private

    def find_first_labtime(file_path, subject)
      dbf_file = ETL::DbfReader.open(file_path)
      l = Labtime.from_s(dbf_file.contents[0][0], {year: subject.admit_date.year, sec: dbf_file.contents[0][1]})

      dbf_file.close
      l
    end

    def find_filename_labtime(file_path)
      time_match = /(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/.match(file_path)

      if time_match
        time_captures = time_match.captures.map {|capture| capture.to_i}

        month = time_captures[0]
        day = time_captures[1]
        year = time_captures[2] < 50 ? time_captures[2] + 2000 : time_captures[2] + 1900
        hour = time_captures[3]
        min = time_captures[4]

        Labtime.parse(Time.zone.local(year, month, day, hour, min))
      else
        nil
      end
    end

    def check_columns(dbf_file)
      if @column_defs
        @column_defs.each_with_index do |col_name, i|
          raise StandardError, "Column definition mismatch for #{dbf_file.file_path}! required: #{@column_defs} | file has: #{dbf_file.columns}" unless dbf_file.columns[i] == col_name
        end
      end
    end

  end
end