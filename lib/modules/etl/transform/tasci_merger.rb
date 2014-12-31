require 'csv'

module ETL
  class TasciMerger
    LIST_DIR  = "/usr/local/htdocs/access/lib/data/etl/klerman_merge_tasci_files/file_lists/"
    T_DRIVE_DIR = "/home/pwm4/Windows/tdrive/IPM/AFOSR9_Slp_Restrict/"


    def merge_files
      subject_list = load_subject_list
      subject_list.each do |subject_code, file_list|
        merged_file = CSV.open("/usr/local/htdocs/access/lib/data/etl/klerman_merge_tasci_files/merged_files/#{subject_code}_merged.csv", "wb")
        merged_file << %w(SUBJECT_CODE LABTIME SLEEP_STAGE SLEEP_PERIOD SEM_FLAG)

        previous_first_labtime = nil
        previous_last_labtime = nil

        file_list.each do |file_hash|
          matched_files = Dir.glob("#{T_DRIVE_DIR}/#{subject_code}/PSG/TASCI_SEM/*#{file_hash[:pattern]}*.TASCI", File::FNM_CASEFOLD)

          ## Validate File List
          if matched_files.length != 1
            raise StandardError, "None or more than one matched file. #{file_hash[:pattern]} #{matched_files} #{matched_files.length}"
          else
            tasci_file_path = matched_files[0]
          end

          ## Ignore Corrupted Files
          next if tasci_file_path == "/home/pwm4/Windows/tdrive/IPM/AFOSR9_Slp_Restrict//24B7GXT3/PSG/TASCI_SEM/24b7gxt3_082907_wp19ap1_PID_24B7GXT3_082907_WP19AP1_RID_0_SEM.TASCI"

          tasci_file = File.open(tasci_file_path)
          file_info = {}

          ## HEADER INFO
          # Header Line
          tasci_file.readline

          # File Name
          read_line = tasci_file.readline
          matched_name =  /\W*File name \|\W*(.*\.vpd)/i.match(read_line)
          MY_LOG.info "ERROR: #{read_line}" unless matched_name
          file_info[:source_file_name] = matched_name[1]

          # Record Date
          read_line = tasci_file.readline
          matched_date = /RecordDate\W*\|\W*(..)\/(..)\/(....)\W*\|.*/.match(read_line)
          MY_LOG.info "ERROR: #{read_line}" unless matched_date
          #MY_LOG.info "matched_date: #{matched_date[3]} #{matched_date[1]} #{matched_date[2]}"
          file_info[:record_date] = (matched_date ? Time.zone.local(matched_date[3].to_i, matched_date[2].to_i, matched_date[1].to_i) : nil)

          # Record Time
          read_line = tasci_file.readline
          matched_time = /RecordTime\W*\|\W*(..):(..):(..)\W*\|\W*Patient ID\W*\|\W*.*\W*\|/.match(read_line)
          MY_LOG.info "ERROR: #{read_line}" unless matched_time
          file_info[:record_full_time] = ((matched_time and matched_date) ? Time.zone.local(matched_date[3].to_i, matched_date[2].to_i, matched_date[1].to_i, matched_time[1].to_i, matched_time[2].to_i, matched_time[3].to_i) : nil)
          file_info[:record_labtime] = Labtime.parse(file_info[:record_full_time])

          6.times do
            tasci_file.readline
          end

          # Epochs and duration
          read_line = tasci_file.readline
          matched_line = /\W*# Epochs\W*\|\W*(\d+)\W*\|\W*Duration\(S\)\W*\|\W*(\d+)\|/.match(read_line)
          MY_LOG.info "ERROR: #{read_line}" unless matched_line
          file_info[:epochs] = matched_line[1].to_i
          file_info[:epoch_duration] = matched_line[2].to_i

          5.times do
            tasci_file.readline
          end

          ## Validation:
          unless (file_hash[:start_labtime] - file_info[:record_labtime].to_decimal).abs <= 0.001
            MY_LOG.error "Excel and Tasci file start labtimes do not match (#{(file_hash[:start_labtime] - file_info[:record_labtime].to_decimal).abs} difference) for #{File.basename(tasci_file_path)}. \nexcel: #{file_hash[:start_labtime]} tasci: #{file_info[:record_labtime].to_decimal}\n"
            LOADER_LOGGER.info "#{subject_code}, #{file_hash[:pattern]}, start, #{file_hash[:start_labtime]}, #{file_info[:record_labtime].to_decimal}, #{File.basename(tasci_file_path)}"
          end

          MY_LOG.error "For file #{File.basename(tasci_file_path)}, Epoch number from excel file (#{file_hash[:last_line_number]} does not match tasci (#{file_info[:epochs]})\n" unless file_info[:epochs] - 1 == file_hash[:last_line_number]

          #MY_LOG.info tasci_file.readline
          #MY_LOG.info "#{subject_code}    pattern: #{file_pattern}    count: #{matched_files.length}    files: #{matched_files}"
          #MY_LOG.info "#{subject_code}    file: #{tasci_file_path}\n#{file_info.inspect}\n"

          first_labtime = nil
          last_labtime = nil

          until tasci_file.eof?
            line = tasci_file.readline

            matched_line = /(\d+)\|\W*(\d+)\|\W*(\d+)\|\W*(\d+)\|\W*(\d\d):(\d\d):(\d\d)\|\W*(.+)\|\W*(.+)\|/.match(line)
            fields = matched_line.to_a
            fields.delete_at(0)

            raise StandardError, "fields should have 9 fields: #{fields.length} #{fields} #{line}" unless fields.length == 9

            # Calculating labtime is tricky - file may span two days
            calculated_line_time = file_info[:record_full_time] + fields[1].to_i.hours + fields[2].to_i.minutes + fields[3].to_i.seconds
            if calculated_line_time.hour == fields[4].to_i and calculated_line_time.min == fields[5].to_i and calculated_line_time.sec == fields[6].to_i
              line_time = calculated_line_time
              line_labtime = Labtime.parse(line_time)
            elsif file_info[:record_full_time].dst? != calculated_line_time.dst?
              if (calculated_line_time.hour - fields[4].to_i).abs == 1 and calculated_line_time.min == fields[5].to_i and calculated_line_time.sec == fields[6].to_i
                line_time = calculated_line_time
                line_labtime = Labtime.parse(line_time)
              else
                raise StandardError, "Times DO NOT MATCH IN TASCI FILE #{File.basename(tasci_file_path)}!!! #{calculated_line_time.to_s} #{fields[4]} #{fields[5]} #{fields[6]}"
              end
            else
              raise StandardError, "Times DO NOT MATCH IN TASCI FILE #{File.basename(tasci_file_path)}!!! #{calculated_line_time.to_s} #{fields[4]} #{fields[5]} #{fields[6]}"
            end

            # Sleep Period Coding:
            # 1      Sleep Onset (Lights Off)
            # 2      Sleep Offset (Lights On)
            if /Lights Off/i.match(fields[7]) # Sleep Onset
              sleep_period = 1
            elsif /Lights On/i.match(fields[7]) # Sleep Offset
              sleep_period = 2
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
            line_event = nil
            if fields[8] == "Awake"
              line_event = 9
            elsif fields[8] == "Undefined"
              line_event = 7
            elsif fields[8] == "1"
              line_event = 1
            elsif fields[8] == "2"
              line_event = 2
            elsif fields[8] == "3"
              line_event = 3
            elsif fields[8] == "4"
              line_event = 4
            elsif fields[8] == "REM"
              line_event = 5
            elsif fields[8] == "MVT"
              line_event = 6
            else
              raise StandardError, "Cannot map the following event: #{fields[8]}"
            end

            # SEM Event Coding:
            # 1      Slow Eye Movement
            # 0      No Slow Eye Movement
            sem_event = (fields[7] =~ /SEM/ ? 1 : 0)

            # Previous Effort:
            #line_time = Time.zone.local(file_info[:record_full_time].year, file_info[:record_full_time].month, file_info[:record_full_time].day, fields[4].to_i, fields[5].to_i, fields[6].to_i)
            #line_labtime = Labtime.parse(line_time)

            first_labtime = line_labtime if first_labtime.nil?
            last_labtime = line_labtime

            output_line = [subject_code.upcase, line_labtime.to_decimal, line_event, sleep_period, sem_event]
            merged_file << output_line


            #MY_LOG.info fields
          end
          if (file_hash[:last_line_labtime] - last_labtime.to_decimal).abs >= 0.001
            MY_LOG.error "Excel and Tasci file end_labtimes do not match (#{(file_hash[:last_line_labtime] - last_labtime.to_decimal).abs} difference) for #{File.basename(tasci_file_path)}.\nexcel: #{file_hash[:last_line_labtime]} tasci: #{last_labtime.to_decimal}\n"
            LOADER_LOGGER.info "#{subject_code}, #{file_hash[:pattern]}, end, #{file_hash[:last_line_labtime]}, #{last_labtime.to_decimal}, #{File.basename(tasci_file_path)}"
          end

          unless previous_first_labtime.nil? or previous_last_labtime.nil?
            MY_LOG.error "Start time is before previous end labtime" if first_labtime < previous_last_labtime
          end


          previous_first_labtime = first_labtime
          previous_last_labtime = last_labtime
        end
        merged_file.close
      end
    end

  end

end

=begin
path: /home/pwm4/Windows/tdrive/IPM/AFOSR9_Slp_Restrict/
path: /usr/local/htdocs/access/lib/data/etl/klerman_merge_tasci_files/file_list

file list:
subject_code ,start time, labtime, last line,last line time,labtime,,,,check,gap

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

