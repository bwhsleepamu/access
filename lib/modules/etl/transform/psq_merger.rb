module ETL
  ## Overview
  # This class will allow the merging of PSQ data into a single spreadsheet that can be loaded using the PSQ Loader.
  # Two types of PSQ source files will be dealt with: Jeanne Duffy's and Elizabeth Klerman's
  # Two merged files will be made as a result.
  # Documentation: 10141 (Jeane Duffy)
  ##





  class PsqMerger
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

    COLUMN_LIST = ["subject_code", "sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "notes"]
    OUTPUT_TYPE = SourceType.find_by_name("Comma Delimited File")
    INPUT_TYPE = SourceType.find_by_name("Excel File")


    def initialize(subject_group, input_file_list, output_file_path)
      @input_file_list = input_file_list
      @output_file_path = output_file_path
      @subject_group = subject_group
    end

    def merge_files
      begin
        merged_source = Source.new(location: @output_file_path)
        CSV.open(@output_file_path, "wb") do |csv|
          csv << COLUMN_LIST
          @input_file_list.each do |input_file_path, columns|
            merged_source.child_sources.build(location: input_file_path)
            xls = Roo::Spreadsheet.open(input_file_path)
            xls.each_with_pagename do |subject_tab, sheet|
              subject_code = subject_tab.upcase
              if @subject_group.subjects.map(&:subject_code).include? subject_code
                (sheet.first_row+1..sheet.last_row).each do |row_num|
                  row = columns.include?("q_2a") ? merge_question_2(columns, sheet.row(row_num)) : sheet.row(row_num)
                  mapped_row = map_row(columns, row, subject_code)
                  csv << mapped_row if mapped_row.present?
                end
              end
            end
          end
        end
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

      valid and row[sp_i].kind_of? Numeric
    end

    def map_row(columns, row, subject_code)
      finalized_row = []
      sc_i = COLUMN_LIST.index("subject_code")
      pde_i = columns.index("person_date_entered")
      note_i = columns.index("notes")

      q_range = (columns.index("q_1")..columns.index("q_8"))

      row[note_i] = "Entered by and on: #{row[pde_i]} | #{row[note_i]}"

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

      finalized_row[sc_i] = subject_code if finalized_row[sc_i].nil? or finalized_row[sc_i] != subject_code

      MY_LOG.info finalized_row

      valid_row?(finalized_row) ? finalized_row : nil
    end
  end
end
