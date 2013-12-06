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

    def initialize(subject_group, input_file_list, output_file_path)
      @file_list = file_list
      @output_file_path = output_file_path
      @subject_group = subject_group


    end

    def merge_files
      begin
        CSV.open(@output_file_path, "wb") do |csv|
          input_file_list.each do |input_file_path|
            xls = Roo::Spreadsheet.open(input_file_path)
            xls.each_with_pagename do |subject_tab, sheet|
              subject_code = subject_tab.upcase
              if @subject_group.subjects.map(&:subject_code).include? subject_code
                sheet.first_row+1..sheet.last_row.each do |row_num|
                  sheet.row(row_num)

                end
              end
            end
          end
        end


      rescue => error

      end
    end
  end
end
