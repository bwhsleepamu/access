module ETL
  ## Overview
  # This class will allow the merging of PSQ data into a single spreadsheet that can be loaded using the PSQ Loader.
  # Two types of PSQ source files will be dealt with: Jeanne Duffy's and Elizabeth Klerman's
  # Two merged files will be made as a result.
  # Documentation: 10141 (Jeane Duffy)
  ##





  class PsqMerger

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

    COLUMN_LIST = ["subject_code", "database_sleep_periods", "sleep_period", "start_sp_guess", "start_sp_start", "start_sp_end", "start_sp_diff", "start_sp_flag", "end_sp_guess", "end_sp_start", "end_sp_end", "end_sp_diff", "end_sp_flag", "sp_number_guess", "sp_number_start", "sp_number_end", "sp_number_diff", "sp_number_flag", "cumulative_minutes", "cumulative_labtime", "time_field", "sp_flag", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "notes", "source_file"]
    OUTPUT_TYPE ="Comma Delimited File"
    INPUT_TYPE = "Excel File"
    USER_EMAIL = "pmankowski@partners.org"


    def initialize(subject_group, input_file_list, output_file_path)
      @input_file_list = input_file_list
      @output_file_path = output_file_path

      @correct_output_path = output_file_path.gsub(".csv", "_correct.csv")
      @missing_output_path = output_file_path.gsub(".csv", "_missing.csv")
      @neither_output_path = output_file_path.gsub(".csv", "_neither.csv")


      @subject_group = subject_group
    end

    def read_klerman_file(input_xls, columns)
      rows_by_subject = {}
      # Klerman Specific
      # 1. Find Subject
      # If code valid:
      #   2. Find Subject Range
      sheet = input_xls.longest_sheet
      (sheet.first_row+1..sheet.last_row).each do |row_num|

        row = columns.include?("q_2a") ? merge_question_2(columns, sheet.row(row_num)) : sheet.row(row_num)
        row_subject = row[columns.index("subject_code")].upcase

        #LOAD_LOG.info row
        #LOAD_LOG.info row_subject


        if subject_code_valid? row_subject, @subject_group
          rows_by_subject[row_subject] = [] unless rows_by_subject.has_key? row_subject
          rows_by_subject[row_subject] << row
        end
      end

      LOAD_LOG.info rows_by_subject

      rows_by_subject

    end


    def read_duffy_file(input_xls, columns)
      rows_by_subject = {}

      # Duffy Specific
      #
      input_xls.each_with_pagename do |subject_tab, sheet|
        subject_code = subject_tab.upcase
        if subject_code_valid? subject_code, @subject_group
          rows_by_subject[subject_code] = []
          (sheet.first_row+1..sheet.last_row).each do |row_num|
            row = columns.include?("q_2a") ? merge_question_2(columns, sheet.row(row_num)) : sheet.row(row_num)
            rows_by_subject[subject_code] << row
          end
        end
      end

      rows_by_subject
    end

    def merge_duffy_files
      merge_files :duffy
    end

    def merge_klerman_files
      merge_files :klerman
    end

    def merge_files(type)
      begin
        # Setup
        output_source_type = SourceType.find_by_name(OUTPUT_TYPE)
        input_source_type = SourceType.find_by_name(INPUT_TYPE)
        user = User.find_by_email(USER_EMAIL)
        merged_source = Source.find_or_initialize_by(location: @output_file_path, source_type_id: output_source_type.id, user_id: user.id)

        subject_lists = {missing_sps: [], no_errors: [], neither: []}

        # Set Up Output Files
        merged_output = CSV.open(@output_file_path, "wb")
        correct_output = CSV.open(@correct_output_path, 'wb')
        missing_output = CSV.open(@missing_output_path, 'wb')
        neither_output = CSV.open(@neither_output_path, 'wb')

        merged_output << COLUMN_LIST
        correct_output << COLUMN_LIST
        missing_output << COLUMN_LIST
        neither_output << COLUMN_LIST


        # Iterate Over Subjects
        @input_file_list.each do |input_file_path, columns|
          merged_source.child_sources << Source.find_or_initialize_by(location: input_file_path, source_type_id: input_source_type.id, user_id: user.id)


          xls_file = Roo::Excel.new(input_file_path)

          if type == :duffy
            rows_by_subject = read_duffy_file(xls_file, columns)
          else
            rows_by_subject = read_klerman_file(xls_file, columns)
          end



          rows_by_subject.each_pair do |subject_code, rows|
            # Initialization
            sp_events = Event.generate_report("sleep_period_start", subject_code: subject_code)[:result].map{|h| [h['period_number'], h['first_decimal_labtime'], h['second_decimal_labtime'], h['first_labtime_year']]}
            added_rows = []
            all_equal_sps = true

            rows.each do |row|
              # Map row values to correct spots
              mapped_row = map_row(columns, row, subject_code, sp_events)


              LOAD_LOG.info "1 #{mapped_row}"

              # If mapping was successful
              if mapped_row.present?
                mapped_row[COLUMN_LIST.index("source_file")] = File.basename(input_file_path)
                LOAD_LOG.info "2 #{mapped_row}"


                # Add to output
                merged_output << mapped_row

                # Save row for subsequent addition to one of the scoped output files
                added_rows << mapped_row

                # Determine if sp numbers agree across row
                all_equal_sps = (all_equal_sps and (mapped_row[COLUMN_LIST.index("sp_flag")] != "X"))
              end
            end
            if (sp_events.length - added_rows.length).abs > 0
              MY_LOG.info "#{subject_code} has incorrect number of Post Sleep Questionnaires: expected: #{sp_events.length} found: #{added_rows.length} in #{File.basename(input_file_path)}"
              subject_lists[:missing_sps] << subject_code
              added_rows.each {|r| missing_output << r}
            elsif all_equal_sps
              MY_LOG.info "#{subject_code} seems to have no errors in #{File.basename(input_file_path)}"
              subject_lists[:no_errors] << subject_code
              added_rows.each {|r| correct_output << r}
            else
              MY_LOG.info "#{subject_code} fits neither category in #{File.basename(input_file_path)}"
              subject_lists[:neither] << subject_code
              added_rows.each {|r| neither_output << r}
            end
          end
        end

        MY_LOG.info "missing sps (#{subject_lists[:missing_sps].length}): #{subject_lists[:missing_sps]}"
        MY_LOG.info "no errors (#{subject_lists[:no_errors].length}): #{subject_lists[:no_errors]}"
        MY_LOG.info "neither (#{subject_lists[:neither].length}): #{subject_lists[:neither]}"

        merged_output.close
        correct_output.close
        missing_output.close
        neither_output.close

        merged_source.save
      rescue => e
        LOAD_LOG.info e
        LOAD_LOG.info e.backtrace
        false
      end
    end


    private



    def merge_question_2(columns, row)
      q_2_index = columns.index("q_2")

      q_2a_val = row.delete_at(q_2_index + 1)

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

      valid and (row[sp_i].kind_of? Numeric or row[COLUMN_LIST.index("time_field")].present?)
    end

    def map_row(columns, row, subject_code, sp_events)
      sp_vals = []
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

      # Insert computed stuff
      cum_min_i = COLUMN_LIST.index("cumulative_minutes")
      cum_labtime_i = COLUMN_LIST.index("cumulative_labtime")
      sp_i = COLUMN_LIST.index("sleep_period")
      sp_guess_i = COLUMN_LIST.index("start_sp_guess")
      sp_flag_i = COLUMN_LIST.index("sp_flag")

      finalized_row[cum_labtime_i] = (finalized_row[cum_min_i].to_f != 0.0) ? (finalized_row[cum_min_i].to_f / 60.0) : nil
      #MY_LOG.info "#{finalized_row[cum_min_i]} #{cum_labtime_i} #{finalized_row[cum_labtime_i - 1]} #{finalized_row.length}==#{COLUMN_LIST.length} || #{finalized_row[cum_min_i].is_a?(Fixnum)}"
      if finalized_row[cum_labtime_i]
        sp_guesses = guess_sleep_period sp_events, finalized_row[cum_labtime_i], finalized_row[sp_i]
      else
        sp_guesses = guess_sleep_period sp_events, finalized_row[COLUMN_LIST.index("time_field")], finalized_row[sp_i]
      end

      #MY_LOG.info "sp_guesses: #{sp_guesses}"

      sp_vals << finalized_row[sp_i]
      finalized_row[cum_labtime_i] = sp_guesses.delete(:cumulative_labtime) unless finalized_row[cum_labtime_i].present?
      finalized_row[sp_i] = sp_guesses.delete(:sleep_period) unless finalized_row[sp_i].present?

      if sp_guesses
        sp_guesses.values.each_with_index do |sp, i|
          if sp
            this_i = (sp_guess_i + (i*5))
            finalized_row[this_i] = sp[0]
            finalized_row[this_i + 1] = sp[1]
            finalized_row[this_i + 2] = sp[2]
            if finalized_row[cum_labtime_i]
              finalized_row[this_i + 3] = (finalized_row[cum_labtime_i] - sp[2]) * 60
              finalized_row[this_i + 4] = "X" if finalized_row[this_i + 3].abs > 60
              finalized_row[this_i + 4] = "XXX" if finalized_row[this_i + 3].abs > 120

            end
            sp_vals << sp[0]
          end
        end

      end

      finalized_row[COLUMN_LIST.index("database_sleep_periods")] = sp_events.length



      #MY_LOG.info sp_vals
      finalized_row[sp_flag_i] = "X" if sp_vals.compact.map(&:to_i).uniq.length > 1

      finalized_row[sc_i] = subject_code #if finalized_row[sc_i].nil? or finalized_row[sc_i] != subject_code
      LOAD_LOG.info "F! #{finalized_row}"

      valid_row?(finalized_row) ? finalized_row : nil
    end

    def subject_code_valid?(subject_code, subject_group)
      if subject_group.nil?
        (Subject::SUBJECT_CODE_REGEX =~ subject_code).present?
      else
        subject_group.subjects.map(&:subject_code).include? subject_code
      end
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
