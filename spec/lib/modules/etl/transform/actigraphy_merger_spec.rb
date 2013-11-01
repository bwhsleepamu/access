require 'spec_helper'
require 'csv'
#require 'fakefs/spec_helpers'



describe ETL::ActigraphyMerger do
  describe "main workflow" do
    it "should create merged files for fd subjects in master list" do
      al = ETL::ActigraphyMerger.new("/usr/local/htdocs/access/spec/data/fd_actigraphy_merger.csv", "/usr/local/htdocs/access/spec/data/merged_actigraphy/fd/")
      al.merge_files
    end
  end
end