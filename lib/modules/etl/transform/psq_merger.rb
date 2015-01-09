module ETL
  ## Overview
  # This class will allow the merging of PSQ data into a single spreadsheet that can be loaded using the PSQ Loader.
  # Two types of PSQ source files will be dealt with: Jeanne Duffy's and Elizabeth Klerman's
  # Two merged files will be made as a result.
  # Documentation: 10141 (Jeane Duffy)
  ##



  ## Call in etl.rake:
=begin
  desc "merge Duffy psq files"
  task :merge_duffy_psq_files => :environment do
    destination_file_path = "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/merged_duffy_psqs.csv"
    source_file_list = {
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/PSQ data sheet Aging PPG CSR study 12-12-08.xls" => ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'],
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/PSQ data sheet for circadian genetics study.xls" => ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'],
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/PSQ data sheet for Vitamin B12 study.xls" => ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'],
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/PSQ data sheet PER3-PPG CSR.xls" => ["subject_code", "sleep_period", "cumulative_minutes", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"],
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/PSQ data YOUNG 20h melatonin study.xls" => ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes']
    }

    psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path
    psq_merger.merge_duffy_files
  end

  desc "merge klerman psq files"
  task :merge_klerman_psq_files => :environment do
    destination_file_path = "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/merged_klerman_psqs.csv"
    source_file_list = {
        "/I/Projects/Database Project/Data Sources/Post Sleep Questionnaires/Klerman PSQ Project (Finished)-ebk.xls" => ['subject_code', 'time_field', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'q_9', 'q_10']
    }

    psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path
    psq_merger.merge_klerman_files
  end
=end


  class PsqMerger

    # Class Methods

    def self.float?(str)
      str =~ /^\s*[+-]?((\d+_?)*\d+(\.(\d+_?)*\d+)?|\.(\d+_?)*\d+)(\s*|([eE][+-]?(\d+_?)*\d+)\s*)$/
    end

    def self.finalize_corrected_file(input_path, output_path)
      # if X, ignore line
      # if labtime exists, make sure it's in decimal form? or non-decimal form?
      # Columns:
      #    subject_code
      #    sleep_period_number
      #    labtime_decimal
      #    labtime_year
      #    labtime_difference
      #    q_1...q_8
      #    notes

      # For Labtime:
      #   Note if SP # labtime is far off -

      input_file = Roo::Excel.new(input_path)
      output_file = CSV.open(output_path, "wb")

      output_columns = [:subject_code, :sleep_period_number, :decimal_labtime, :labtime_year, :sp_labtime, :sp_year, :labtime_difference, :q_1, :q_2, :q_3, :q_4, :q_4a, :q_5, :q_6, :q_7, :q_8, :notes]
      output_file << output_columns


      sheet = input_file.longest_sheet

      current_subject_code = sheet.first_row+1

      (sheet.first_row+1..sheet.last_row).each do |row_num|
        row = sheet.row(row_num)
        if current_subject_code != row[2]
          current_subject_code = row[2]
          current_subject = Subject.find_by_subject_code(current_subject_code)

          sp_events = Event.generate_report("sleep_period_start", subject_code: current_subject_code)[:result].map{|h| [h['period_number'], h['first_decimal_labtime'], h['second_decimal_labtime'], h['first_labtime_year']]}
        end

        row_sp = row[4].to_i
        output_row = [current_subject_code, row_sp]

        if self.float?(row[6])
          row_labtime = Labtime.from_decimal(row[6].to_f, current_subject.admit_year)
        else
          row_labtime = Labtime.from_s(row[6], {year: current_subject.admit_year})
        end

        sp_labtime = sp_events[sp_events.index {|a| a[0] == row_sp}][2]
        sp_year = sp_events[sp_events.index {|a| a[0] == row_sp}][3]


        labtime_difference = row_labtime.to_decimal - sp_labtime

        output_row = [current_subject_code, row_sp, row_labtime.to_decimal, row_labtime.year, sp_labtime, sp_year, labtime_difference]
        output_row += row[8..17]

        output_file << output_row
      end
    end


    # Need:
    #   file list

    # Merged file for JD subjects:
    #   subject_code, sleep_period, questions 1..??

    # Documentation:
    #   Add docs for PSQ Sheet
    #   Add docs for Klerman PSQ files



    # Sources:
    #   Add source types for
    #    JD PSQ files
    #    EK PSQ files
    #    Merged PSQ files


    # Columns:
    # - subject_code
    # - sleep_period
    # - lights_out_labtime_decimal
    # - q_1..q_8 (q2, q2a)
    # - preson_date_entered
    # - notes

=begin
    {
        "PSQ data sheet PER3-PPG CSR.xls" => ["subject_code", "sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"],
        "PSQ data sheet Aging PPG CSR study 12-12-08.xls" => ["sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"],
        "PSQ data sheet for circadian genetics study.xls" => ["sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "notes"],
        "PSQ data sheet for Vitamin B12 study.xls" => ["sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_2a", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "notes"],
        "PSQ data YOUNG 20h melatonin study.xls" => ["sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_2a", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"]
    }
=end

#    COLUMN_LIST = ["subject_code", "database_sleep_periods", "sleep_period", "start_sp_guess", "start_sp_start", "start_sp_end", "start_sp_diff", "start_sp_flag", "end_sp_guess", "end_sp_start", "end_sp_end", "end_sp_diff", "end_sp_flag", "sp_number_guess", "sp_number_start", "sp_number_end", "sp_number_diff", "sp_number_flag", "cumulative_minutes", "cumulative_labtime", "time_field", "sp_flag", "q_1", "q_2", "q_3", "q_4", "q_5", "q_6", "q_7", "q_8", "notes", "source_file"]

    COLUMN_LIST = ["subject_code", "sleep_period", "cumulative_labtime", "cumulative_minutes", "time_field", "q_1", "q_2", "q_3", "q_4", "q_5", "q_6", "q_7", "q_8", "notes", "source_file"]
    OUTPUT_TYPE ="Comma Delimited File"
    INPUT_TYPE = "Excel File"
    USER_EMAIL = "pmankowski@partners.org"


    def initialize(input_file_list, output_file_path)
      @input_file_list = input_file_list
      @output_file_path = output_file_path
    end


    ## MAIN FUNCTION
    def merge_files
      begin
        # Setup
        #output_source_type = SourceType.find_by_name(OUTPUT_TYPE)
        #user = User.find_by_email(USER_EMAIL)

        #merged_source = Source.find_or_initialize_by(location: @output_file_path, source_type_id: output_source_type.id, user_id: user.id)

        #subject_lists = {missing_sps: [], no_errors: [], neither: []}

        # Set Up Output Files
        merged_output = CSV.open(@output_file_path, "wb")
        #correct_output = CSV.open(@correct_output_path, 'wb')
        #missing_output = CSV.open(@missing_output_path, 'wb')
        #neither_output = CSV.open(@neither_output_path, 'wb')

        merged_output << COLUMN_LIST
        #correct_output << COLUMN_LIST
        #missing_output << COLUMN_LIST
        #neither_output << COLUMN_LIST


        # Iterate Over Subjects
        # Example Hash:
        # { source_id: 95375683, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },

        @input_file_list.each do |input_file_hash|
          columns = input_file_hash[:columns]

          #input_source = Source.find(input_file_hash[:source_id])
          #merged_source.child_sources << input_source

          LOAD_LOG.info "Loading file: #{input_file_hash[:location]}"

          if input_file_hash[:file_type] == :single_sheet
            # ** - Klerman
            rows_by_subject = read_single_sheet_file(input_file_hash[:location], columns)
          else
            # ** - Duffy
            rows_by_subject = read_multiple_sheet_file(input_file_hash[:location], columns)
          end

          # ** - Delete redundant column names?
          columns = correct_column_values(columns)

          # Info is read, now we iterate over each row
          rows_by_subject.each_pair do |subject_code, rows|

            # Initialization

            ## Loads sleep episodes for subject
            #sp_events = Event.generate_report("sleep_period_start", subject_code: subject_code)[:result].map{|h| [h['period_number'], h['first_decimal_labtime'], h['second_decimal_labtime'], h['first_labtime_year']]}

            #all_equal_sps = true

            MY_LOG.info "!!! #{rows.length}"

            rows.each do |row|
              # ** - Map row values to correct spots
              mapped_row = map_row(columns, row, subject_code)


              #MY_LOG.info "1 #{mapped_row}"

              # If mapping was successful
              if mapped_row.present?
                MY_LOG.info "!!!! #{mapped_row}"
                mapped_row[COLUMN_LIST.index("source_file")] = File.basename(input_file_hash[:location])
                #MY_LOG.info "2 #{mapped_row}"


                # Add to output
                merged_output << mapped_row

              end
            end

          end
        end

        merged_output.close

      rescue => e
        LOAD_LOG.info e
        LOAD_LOG.info e.backtrace
        false
      end
    end


    private


    ## Klerman-specific
    # def read_single_sheet_file(input_file_path, columns)
    #
    #   input_xls = Roo::Excel.new(input_file_path)
    #
    #
    #   rows_by_subject = {}
    #   # Klerman Specific
    #   # 1. Find Subject
    #   # If code valid:
    #   #   2. Find Subject Range
    #   sheet = input_xls.longest_sheet
    #
    #
    #   LOAD_LOG.info "Reading file with columns: #{columns}. Rows #{sheet.first_row} to #{sheet.last_row}"
    #
    #   (sheet.first_row+1..sheet.last_row).each do |row_num|
    #     row = merge_row_values(columns, sheet.row(row_num))
    #
    #     row_subject = row[columns.index("subject_code")]
    #     row_subject = row_subject.upcase if row_subject
    #
    #     if subject_code_valid? row_subject
    #       # LOAD_LOG.info row
    #       # LOAD_LOG.info row_subject
    #
    #       rows_by_subject[row_subject] = [] unless rows_by_subject.has_key? row_subject
    #       rows_by_subject[row_subject] << row
    #     end
    #   end
    #
    #   MY_LOG.info "Rows for #{input_file_path}: #{rows_by_subject}"
    #
    #   rows_by_subject
    # end



    # Duffy Specific
    def read_multiple_sheet_file(input_file_path, columns)
      input_xls = Roo::Excel.new(input_file_path)

      LOAD_LOG.info "Reading file with columns: #{columns}"

      rows_by_subject = {}

      # Duffy Specific
      #
      input_xls.each_with_pagename do |subject_tab, sheet|
        subject_code = subject_tab.upcase
        if subject_code_valid? subject_code
          rows_by_subject[subject_code] = []
          (sheet.first_row+1..sheet.last_row).each do |row_num|
            row = merge_row_values(columns, sheet.row(row_num))
#            row = columns.include?("q_2a") ? merge_question_2(columns, sheet.row(row_num)) : sheet.row(row_num)
            rows_by_subject[subject_code] << row
          end
        end
      end

      rows_by_subject
    end


    def merge_row_values(columns, row)
      # Merge redundant information
      my_columns = columns.clone

      #MY_LOG.info "####"
      #MY_LOG.info my_columns
      #MY_LOG.info row
      #MY_LOG.info "##"
      if my_columns.include?("q_2a")
        #MY_LOG.info "Q2"
        row = merge_question_2(my_columns, row)
        my_columns.delete("q_2a")
        #MY_LOG.info "##"
        #MY_LOG.info my_columns
        #MY_LOG.info row
      end
      if my_columns.include?("q_4a")
        #MY_LOG.info "##"
        #MY_LOG.info "Q4"
        row = merge_question_4(my_columns, row)
        my_columns.delete("q_4a")
        #MY_LOG.info "##"
        #MY_LOG.info my_columns
        #MY_LOG.info row
      end
      #MY_LOG.info "####\n"

      row
    end


    def correct_column_values(columns)
      if columns.include?("q_2a")
        columns.delete("q_2a")
      end

      if columns.include?("q_4a")
        columns.delete("q_4a")
      end

      columns
    end

    def merge_question_4(columns, row)
      q_4_index = columns.index("q_4")

      q_4a_val = row.delete_at(q_4_index + 1)

      #MY_LOG.info "!!!! row: #{row} | index: #{q_4_index} | val: #{q_4a_val} | q4: #{row[q_4_index]}"

      if row[q_4_index] == 1
        row[q_4_index] = 0
      else
        row[q_4_index] = q_4a_val
      end

      #MY_LOG.info "NEW: #{row[q_4_index]} | #{row}"

      row
    end

    def merge_question_2(columns, row)
      q_2_index = columns.index("q_2")

      q_2a_val = row.delete_at(q_2_index + 1)

      #MY_LOG.info "!!#{q_2_index} | #{q_2a_val} | #{row[q_2_index]}"

      if row[q_2_index] == 1
        row[q_2_index] = q_2a_val
      end

      row
    end

    def valid_row?(row)
      valid = false
      sp_i = COLUMN_LIST.index("sleep_period")
      q_range = (COLUMN_LIST.index("q_1")..COLUMN_LIST.index("q_8"))

      q_range.each do |i|
        valid = true if row[i].present?
      end

      #valid = (valid and (row[sp_i].kind_of? Numeric or row[COLUMN_LIST.index("time_field")].present?))
      MY_LOG.info "VALID: #{valid}"

      valid


    end

    def map_row(columns, row, subject_code)
      finalized_row = []
      sc_i = COLUMN_LIST.index("subject_code")
      pde_i = columns.index("person_date_entered")
      note_i = columns.index("notes")

      q_range = (columns.index("q_1")..columns.index("q_8"))
      row[note_i] = "Entered by and on: #{row[pde_i]} | #{row[note_i]}" unless pde_i.nil?


      COLUMN_LIST.each do |name|
        row_i = columns.index(name)
        if row_i
          if q_range.include? row_i
            finalized_row << (row[row_i].kind_of?(Numeric) ? row[row_i] : nil)
          else
            finalized_row << row[row_i]
          end
        else
          finalized_row << nil
        end
      end

      sp_i = COLUMN_LIST.index("sleep_period")
      cum_min_i = COLUMN_LIST.index("cumulative_minutes")
      cum_labtime_i = COLUMN_LIST.index("cumulative_labtime")

      if finalized_row[sp_i].present? and finalized_row[sp_i].to_s =~ /\A[+-]?\d+?(\.\d+)?\Z/
        finalized_row[sp_i] = finalized_row[sp_i].to_f
      end

      finalized_row[cum_labtime_i] = (finalized_row[cum_min_i].to_f != 0.0) ? (finalized_row[cum_min_i].to_f / 60.0) : nil

      finalized_row[sc_i] = subject_code #if finalized_row[sc_i].nil? or finalized_row[sc_i] != subject_code

      MY_LOG.info "F! #{finalized_row}"

      valid_row?(finalized_row) ? finalized_row : nil
    end

    def subject_code_valid?(subject_code)
      (Subject::SUBJECT_CODE_REGEX =~ subject_code).present?
    end


    def guess_sleep_period(sp_events, field_to_match, sp_field)
      MY_LOG.info "ftm: #{field_to_match} sp_field: #{sp_field}"
      guesses = {start_of_sp: nil, end_of_sp: nil, sp_number: nil, cumulative_labtime: nil}
      threshold = 60 # in minutes
      labtime = nil
      period = sp_field.to_i

      if field_to_match =~ /(\d+):(\d*)/
        labtime = $1.to_f + $2.to_f/60.0
      elsif field_to_match =~ /sp\s*(\d+)/i
        period = $1.to_i
      elsif field_to_match.is_a? Date
        dt = field_to_match
        labtime = Labtime.parse(Time.zone.local(dt.year, dt.month, dt.day)).to_decimal
      elsif field_to_match.to_f != 0.0
        labtime = field_to_match.to_f
      end

      if labtime
        # match start
        guesses[:start_of_sp] = sp_events.min_by {|x| (x[1] - labtime).abs }
        # match end
        guesses[:end_of_sp] = sp_events.min_by {|x| (x[2] - labtime).abs }
        guesses[:cumulative_labtime] = labtime

      end

      # match sp
      #MY_LOG.info "PERIOD: #{period}"
      if period > 0
        guesses[:sp_number] = sp_events.select{|x| x[0] == period }.first
        guesses[:sleep_period] = period
      end
      guesses
    end
  end
end
