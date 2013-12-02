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
  let(:destination_file_path) {"/usr/local/htdocs/access/spec/data/merged_psq/merged_d.csv"}
  describe "Merging of Jeanne Duffy files" do
    it "should merge all tabs in the template source into a master xls (csv?) file" do
      # 8 subjects * 23 SP + 1 subject * 12 SP

      File.delete destination_file_path

      psq_merger = ETL::PsqMerger.new subject_group, source_file_list, destination_file_path

      expect(psq_merger.merge_files).to be_true

      expect(File.exists? destination_file_path).to be_true
      expect(File.open(destination_file_path).readlines.size).to eq((8 * 23) + (1 * 12))
    end

  end

end

