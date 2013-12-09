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
  let(:destination_file_path) {"/usr/local/htdocs/access/spec/data/psq_merger/merged_d.csv"}
  describe "Merging of Jeanne Duffy files" do
    let(:source_file_list) {
      {
          "/usr/local/htdocs/access/spec/data/psq_merger/psq_merger_d.xls" => ["subject_code", "sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"],
          "/usr/local/htdocs/access/spec/data/psq_merger/psq_merger_d2.xls" => ["sleep_period", "lights_out_labtime_decimal", "q_1", "q_2", "q_2a", "q_3", "q_4", "q_4a", "q_5", "q_6", "q_7", "q_8", "person_date_entered", "notes"]
      }
    }

    it "should merge all tabs in the template source into a master xls (csv?) file" do
      # 8 subjects * 23 SP + 1 subject * 12 SP
      subject_group = create(:subject_group_with_subjects, subject_code_list: ["1732MX", "1712MX", "1684MX", "29U2X0T1", "2701X0T4", "3017X", "3018X", "3038X", "3075X", "3098X", "30C6X", "30E1X"])

      File.delete destination_file_path if File.exists? destination_file_path

      psq_merger = ETL::PsqMerger.new subject_group, source_file_list, destination_file_path

      expect(psq_merger.merge_files).to be_true

      expect(File.exists? destination_file_path).to be_true
      expect(File.open(destination_file_path).readlines.size).to eq(1 + (8 * 23) + (1 * 12) + 28 + 27 + 25)

      expect(Source.all.count).to eq(3)
    end
  end
end
