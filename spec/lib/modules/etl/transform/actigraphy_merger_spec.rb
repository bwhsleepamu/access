require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'

describe ETL::ActigraphyMerger do
  describe "main workflow" do
    # change master path
    let(:master_path) {"/I/Projects/Database Project/Data Sources/Actigraphy/FD-Actigraphy_2015_03_30.csv"}
    # let(:master_path) {"/usr/local/htdocs/access/spec/data/fd_actigraphy_merger.csv"}
    let(:output_dir) { "/usr/local/htdocs/access/spec/data/merged_actigraphy/fd/" }

    before do
      Dir.foreach(output_dir) do |f|
        File.delete(File.join(output_dir, f)) if f != '.' && f != '..'
      end
    end

    it "should create merged files for fd subjects in master list" do

      am = ETL::ActigraphyMerger.new(master_path, output_dir)
      am.merge_files

      expect(Dir[File.join(output_dir, '**', '*')].count { |file| File.file?(file) }).to eq(4)

      Dir.foreach(output_dir) do |f|
        expect(File.size(File.join(output_dir, f))).to be > 0 if f != '.' && f != '..'
      end
    end

    it "should create ignore unauthorized subjects" do
      s = create(:subject, subject_code: "3228GX")

      am = ETL::ActigraphyMerger.new(master_path, output_dir, [s])
      am.merge_files

      expect(Dir[File.join(output_dir, '**', '*')].count { |file| File.file?(file) }).to eq(2)
    end
  end
end
