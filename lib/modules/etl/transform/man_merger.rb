require 'csv'

## CHANGELOG
# 2173 Master file: change sp16,17,18 to *_rev

module ETL
  class ManMerger
    LIST_DIR  = "/usr/local/htdocs/access/lib/data/etl/klerman_merge_man_files/file_lists/"
    T_DRIVE_DIRS = ["/home/pwm4/Windows/tdrive/IPM/Modafinil_FD_42.85h/", "/home/pwm4/Windows/tdrive/IPM/NSBRI_65d_Entrainment/"]
    #T_DRIVE_DIR = "/home/pwm4/Windows/tdrive/IPM/Modafinil_FD_42.85h/"
    EPOCH_LENGTH = 30

    def merge_files
      subject_list = load_subject_list
      subject_list.each do |subject_code, file_list|
        merged_file = CSV.open("/usr/local/htdocs/access/lib/data/etl/klerman_merge_man_files/merged_files/#{subject_code}_merged.csv", "wb")
        merged_file << %w(SUBJECT_CODE LABTIME SLEEP_STAGE SLEEP_PERIOD SEM_FLAG)
        MY_LOG.info "---- #{subject_code}"

        previous_first_labtime = nil
        previous_last_labtime = nil
        subject_year = get_subject_year(file_list)

        file_list.each do |file_hash|
          matched_files = Dir.glob("#{T_DRIVE_DIRS[0]}#{subject_code}/PSG/SCORED/**/#{file_hash[:pattern]}.man", File::FNM_CASEFOLD)
          matched_files = Dir.glob("#{T_DRIVE_DIRS[1]}#{subject_code}/Sleep/#{file_hash[:pattern]}.man", File::FNM_CASEFOLD) if matched_files.length != 1

          ## Validate File List
          if matched_files.length != 1
            raise StandardError, "None or more than one matched file. #{file_hash[:pattern]} #{matched_files} #{matched_files.length} #{subject_code}"
          else
            man_file_path = matched_files[0]
          end

          man_file = File.open(man_file_path)
          LOADER_LOGGER.info "--- Loading #{man_file_path}"
          file_info = {}


          ## Ignore Corrupted Files
          #next if tasci_file_path == "/home/pwm4/Windows/tdrive/IPM/AFOSR9_Slp_Restrict//24B7GXT3/PSG/TASCI_SEM/24b7gxt3_082907_wp19ap1_PID_24B7GXT3_082907_WP19AP1_RID_0_SEM.TASCI"

          # Date from file name
          matched_date = /_(\d\d)(\d\d)(\d\d)_/.match(man_file_path)
          file_info[:fn_date] = (matched_date ? Time.zone.local((matched_date[3].to_i > 30 ? matched_date[3].to_i + 1900 : matched_date[3].to_i + 2000), matched_date[1].to_i, matched_date[2].to_i) : nil)

          # read file
          lines = man_file.readlines("\r")
          # delete possible empty last line
          lines.pop if lines.last.blank?

          # get file first and last times
          matched_time = /(\d\d):(\d\d):(\d\d):(\d\d\d)/.match(lines.first)
          file_info[:first_time] = {hour: matched_time[1].to_i, min: matched_time[2].to_i, sec: matched_time[3].to_i}
          matched_time = /(\d\d):(\d\d):(\d\d):(\d\d\d)/.match(lines.last)
          file_info[:last_time] = {hour: matched_time[1].to_i, min: matched_time[2].to_i, sec: matched_time[3].to_i}

          # validate first/last times
          if file_hash[:start_time] != file_info[:first_time]
            MY_LOG.error "---- FIRST TIME MISMATCH ---\n#{man_file_path}\n#{file_hash[:start_time]} #{file_info[:first_time]}\n\n"
          end
          if file_hash[:last_line_time] != file_info[:last_time]
            MY_LOG.error "---- LAST TIME MISMATCH ----\n#{man_file_path}\n#{file_hash[:last_line_time]} #{file_info[:last_time]}\n\n"
          end
          if file_hash[:last_line_number] != lines.length
            MY_LOG.error "---- LINE COUNT MISMATCH ----\n#{man_file_path}\n#{file_hash[:last_line_number]} #{lines.length}\n\n"
          end

          ##
          # VALIDATION
          file_hash[:start_labtime] = Labtime.from_decimal(file_hash[:start_labtime], subject_year)
          file_hash[:last_line_labtime] = Labtime.from_decimal(file_hash[:last_line_labtime], subject_year)

          start_realtime = file_hash[:start_labtime].to_time
          last_line_realtime = file_hash[:last_line_labtime].to_time

          first_realtime = file_hash[:start_labtime].time_zone.local(start_realtime.year, start_realtime.month, start_realtime.day, file_info[:first_time][:hour], file_info[:first_time][:min], file_info[:first_time][:sec])
          last_realtime = file_hash[:last_line_labtime].time_zone.local(last_line_realtime.year, last_line_realtime.month, last_line_realtime.day, file_info[:last_time][:hour], file_info[:last_time][:min], file_info[:last_time][:sec])

          file_info[:first_labtime] = Labtime.parse(first_realtime)
          file_info[:last_labtime] = Labtime.parse(last_realtime)
          predicted_last_labtime = Labtime.parse(file_info[:first_labtime].to_time + ((lines.length - 1) * 30).seconds)

          sep = false
          if (file_hash[:start_labtime].time_in_seconds - file_info[:first_labtime].time_in_seconds).abs > 2
            MY_LOG.error "---- FIRST LABTIME MISMATCH ----\n#{man_file_path}\n#{file_hash[:start_labtime].time_in_seconds - file_info[:first_labtime].time_in_seconds} | #{file_hash[:start_labtime].to_time}\n#{file_hash[:start_labtime]} | #{file_info[:first_labtime]}\n"
            sep = true
          end

          # These checks fail if DST TRANSITION HAPPENS
          if last_line_realtime.dst? == start_realtime.dst?
            if (file_hash[:last_line_labtime].time_in_seconds - file_info[:last_labtime].time_in_seconds).abs > 2
              MY_LOG.error "---- LAST LABTIME MISMATCH  ----\n#{man_file_path}\n#{file_hash[:last_line_labtime].time_in_seconds - file_info[:last_labtime].time_in_seconds} | #{file_hash[:last_line_labtime].to_time}\n#{file_hash[:last_line_labtime]} | #{file_info[:last_labtime]}\n"
              sep = true
            end
            if (file_info[:last_labtime].time_in_seconds - predicted_last_labtime.time_in_seconds).abs > 0
              MY_LOG.error "---- PRED LABTIME MISMATCH  ----\n#{man_file_path}\n#{(file_info[:last_labtime].time_in_seconds - predicted_last_labtime.time_in_seconds)} | #{predicted_last_labtime.to_time}\nl: #{file_info[:last_labtime]} | #{predicted_last_labtime}\n"
              sep = true
            end
          end

          if (file_hash[:last_line_labtime].time_in_seconds - predicted_last_labtime.time_in_seconds).abs > 2
            MY_LOG.error "---- !PRED LABTIME MISMATCH ----\n#{man_file_path}\n#{(file_hash[:last_line_labtime].time_in_seconds - predicted_last_labtime.time_in_seconds)} | #{predicted_last_labtime.to_time}\nl: #{file_info[:last_line_labtime]} | #{predicted_last_labtime}\n"
            sep = true
          end

          unless previous_first_labtime.nil? or previous_last_labtime.nil?
            MY_LOG.error "Start time is before previous end labtime for #{man_file_path}" if file_info[:first_labtime] < previous_last_labtime
          end

          raise StandardError, "AHHHHH" if file_info[:first_labtime].sec != first_realtime.sec
          raise StandardError, "AHHHHH" if file_info[:last_labtime].sec != last_realtime.sec

          MY_LOG.info "-----------------------------------\n\n" if sep

          last_labtime = nil
          ibob_flag = 0

          lines.each_with_index do |line, line_number|
            #merged_file << %w(SUBJECT_CODE LABTIME SLEEP_STAGE SLEEP_PERIOD SEM_FLAG)
=begin
sleep man file:
  0      undef/unscored
  1      stage 1
  2      stage 2
  3      stage 3
  4      stage 4
  5      wake
  6      REM
  7      MVT
  8      LOff and LOn

wake man file:
  0      undef/un
cored
  1      stage 1
  2      stage 2
  3      stage 3
  4      stage 4
  5      wake
  6      REM
  7      MVT
  8      SEM
=end


            line_labtime = file_info[:first_labtime].add_seconds(EPOCH_LENGTH * line_number)
            line_code = /(\d)\s\d\d:\d\d:\d\d:\d\d\d/.match(line)[1].to_i

            # Sleep Period Coding:
            # 1      Sleep Onset (Lights Off) (IN BED)
            # 2      Sleep Offset (Lights On) (OUT OF BED)
            if file_hash[:type] == :sleep and line_code == 8
              if ibob_flag == 0
                sleep_period = 1
                ibob_flag = 1
              else
                sleep_period = 2
                ibob_flag = 0
              end
            else
              sleep_period = nil
            end

            # Sleep Stage Coding:
            # 1      stage 1
            # 2      stage 2
            # 3      stage 3
            # 4      stage 4
            # 6      MT
            # 7      Undef
            # 5      REM
            # 9      Wake
            if line_code >= 1 and line_code <= 4
              line_event = line_code
            elsif line_code == 0
              line_event = 7
            elsif line_code == 5 or line_code == 8
              line_event = 9
            elsif line_code == 6
              line_event = 5
            elsif line_code == 7
              line_event = 6
            else
              raise StandardError, "Cannot map the following event: #{line_code}"
            end

            # SEM Event Coding:
            # 1      Slow Eye Movement
            # 0      No Slow Eye Movement
            if file_hash[:type] == :wake and line_code == 8
              sem_event = 1
            else
              sem_event = 0
            end

            last_labtime = line_labtime

            output_line = [subject_code.upcase, line_labtime.to_decimal, line_event, sleep_period, sem_event]
            merged_file << output_line
          end


          previous_first_labtime = file_info[:first_labtime]
          previous_last_labtime = last_labtime

        end
        merged_file.close
        MY_LOG.info "---- end #{subject_code}\n\n"

      end
    end

    def load_subject_list
      subject_info = {}
      Dir.foreach(LIST_DIR) do |file|
        next if file == '.' or file == '..'
        #MY_LOG.info "#{file}"
        csv_file = CSV.open("#{LIST_DIR}#{file}", {headers: true})

        # Match and Validate File Name
        matched_sc = /(.*)SLEEP\.csv/i.match(File.basename(csv_file.path))
        if matched_sc
          subject_code = matched_sc[1].upcase
        else
          next
        end

        subject_info[subject_code] = []
        csv_file.each do |row|
          file_info = {}
          pattern = /(.*)\.man/i.match(row[0])

          matched_time = /(\d\d):(\d\d):(\d\d):(\d\d\d)/.match(row[1])
          if matched_time
            file_info[:start_time] = {hour: matched_time[1].to_i, min: matched_time[2].to_i, sec: matched_time[3].to_i}
          else
            MY_LOG.error "No Valid Start Time Found: #{row}"
            next
          end

          matched_time = /(\d\d):(\d\d):(\d\d):(\d\d\d)/.match(row[4])
          if matched_time
            file_info[:last_line_time] = {hour: matched_time[1].to_i, min: matched_time[2].to_i, sec: matched_time[3].to_i}
          else
            MY_LOG.error "No Valid End Time Found: #{row}"
            next
          end

          file_info[:start_labtime] = row[2].to_f
          file_info[:last_line_number] = row[3].to_i
          file_info[:last_line_labtime] = row[5].to_f

          if pattern
            file_info[:pattern] = pattern[1]
            subject_info[subject_code] << file_info

            # Determine if sleep or wake file
            raise StandardError, "CAN'T DETERMINE SP/WP (none match): #{pattern[1]}" unless (/_sp?\d/i.match(pattern[1]) or /_wp?\d/i.match(pattern[1]))
            raise StandardError, "CAN'T DETERMINE SP/WP (both match): #{pattern[1]}" if (/_sp?\d/i.match(pattern[1]) and /_wp?\d/i.match(pattern[1]))

            if /_sp?\d/i.match(pattern[1])
              file_info[:type] = :sleep
            elsif /_wp?\d/i.match(pattern[1])
              file_info[:type] = :wake
            else
              raise StandardError, "Didn't match any SP/WP..."
            end
          else
            MY_LOG.info "No Valid File Name Found: #{row}"
            next
          end
        end
        #MY_LOG.info subject_info[subject_code]
      end
      #MY_LOG.info subject_info.inspect
      subject_info
    end

    def get_subject_year(file_list)
      years = file_list.map do |h|
        matched_date = /_(\d\d)(\d\d)(\d\d)_/.match(h[:pattern])
        matched_date ? matched_date[3] : nil
      end
      years.delete_if {|x| x.nil? }
      years = years.uniq

      raise StandardError, "More than one unique year found in files: #{years}" if years.length > 1
      year = years.first.to_i
      year > 30 ? year + 1900 : year + 2000
    end
  end


end

=begin
path: /home/pwm4/Windows/tdrive/IPM/Modafinil_FD_42.85h/
path: /usr/local/htdocs/access/lib/data/etl/klerman_merge_man_files/file_list

file list:
subject_code ,start time, labtime, last line,last line time,labtime,,,,check,gap

sleep man file:
  0      undef/unscored
  1      stage 1
  2      stage 2
  3      stage 3
  4      stage 4
  5      wake
  6      REM
  7      MVT
  8      LOff and LOn

wake man file:
  0      undef/unscored
  1      stage 1
  2      stage 2
  3      stage 3
  4      stage 4
  5      wake
  6      REM
  7      MVT
  8      SEM


sleep stage 8 should be coded as Wake with a SEM
5 is Wake
1-4 is Sleep stage 1-4
7 is REM
8 is Wake with SEM plus LOff and Lon


mapping:
  1      stage 1
  2      stage 2
  3      stage 3
  4      stage 4
  6      MT
  7      Undef
  5      REM
  9      Wake
=end

