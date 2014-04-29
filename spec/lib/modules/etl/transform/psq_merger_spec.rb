##
# Take data from wide range of PSQ sources (Duffy, Klerman) and merge into a master file ==> load into the database
##

##
# Parameters:
#
# List of subjects (subject group)
# List of source files
#   1. xls file tabs / subject
#   one file / subject
#   etc
require 'spec_helper'
require 'csv'

describe ETL::PsqMerger do
  before do
    csv_type = create(:source_type, name: "Comma Delimited File")
    excel_type = create(:source_type, name: "Excel File")

    create(:user, email: 'pmankowski@partners.org')
    ed1 = create(:event_dictionary, name: "sleep_period_start")
    ed2 = create(:event_dictionary, name: "sleep_period_end")
    ed1.paired_event_dictionary = ed2
    ed1.save

    @m1 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/multiple_sheet_1.xls")
    @m2 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/multiple_sheet_2.xls")
    @m3 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/multiple_sheet_3.xls")
    @s1 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/single_sheet_1.xls")
    @s2 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/single_sheet_2.xls")
    @s3 = create(:source, source_type: excel_type, location: "/usr/local/htdocs/access/spec/data/psq_merger/single_sheet_3.xls")
  end

  describe "Merging of files with multiple sheets" do
    let(:destination_file_path) {"/usr/local/htdocs/access/spec/data/psq_merger/merged_multiple.csv"}
    let(:source_file_list) {
      [
          { source_id: @m1.id, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },
          { source_id: @m2.id, column_map: ["subject_code", "sleep_period", "cumulative_minutes", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"], file_type: :multiple_sheets },
          { source_id: @m3.id, column_map: ['sleep_period', 'cumulative_minutes', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'notes'], file_type: :multiple_sheets },
      ]
    }


    it "should merge all tabs in the template source into a master xls (csv?) file" do
      # 8 subjects * 23 SP + 1 subject * 12 SP

      File.delete destination_file_path if File.exists? destination_file_path

      psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path

      expect(psq_merger.merge_files).to be_true

      expect(File.exists? destination_file_path).to be_true
      expect(File.open(destination_file_path).readlines.size).to be >= 100

      expect(Source.all.count).to eq(7)
    end

  end

  describe "Merging of files with a single sheet" do
    let(:destination_file_path) {"/usr/local/htdocs/access/spec/data/psq_merger/merged_single.csv"}
    let(:source_file_list) {
      [
          { source_id: @s1.id, column_map: ['subject_code', 'sleep_period', 'sp_length', 'time_field', 'q_1', 'q_2', 'q_3', 'q_4', 'q_5', 'q_6', 'q_7', 'q_8', 'comments'], file_type: :single_sheet },
          { source_id: @s2.id, column_map: ['subject_code', 'sleep_period', 'pre_sp_protocol', 'sp_duration', 'time_field', 'q_1', 'q_2', 'q_3', 'q_4', 'q_5', 'q_6', 'q_7', 'q_8'], file_type: :single_sheet },
          { source_id: @s3.id, column_map: ['subject_code', 'time_field', 'q_1', 'q_2', 'q_2a', 'q_3', 'q_4', 'q_4a', 'q_5', 'q_6', 'q_7', 'q_8', 'q_9', 'q_10'], file_type: :single_sheet },
      ]
    }

    it "should merge the given files into destination path" do
      File.delete destination_file_path if File.exists? destination_file_path

      psq_merger = ETL::PsqMerger.new nil, source_file_list, destination_file_path

      expect(psq_merger.merge_files).to be_true

      expect(File.open(destination_file_path).readlines.size).to be >= 100

      MY_LOG.info Source.all.map(&:location)

      expect(Source.all.count).to eq(7)
    end

  end

end
