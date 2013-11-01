require 'spec_helper'

describe ETL::DbfReader do
  describe "initialization" do
    it "should make deleted rows in a dbf file accessible" do
      file_path = "/usr/local/htdocs/access/spec/data/TEST_EMPTY.DBF"

      dbf_file = DBF::Table.new(file_path)
      dbf_file.find(1).should be_nil
      dbf_file.close

      dbf_reader = ETL::DbfReader.open(file_path)

      dbf_reader.dbf.find(1).should_not be_nil

    end

    it "should not change contents of the dbf file" do
      file_path = "/usr/local/htdocs/access/spec/data/TEST_CLEAN.DBF"
      dbf_file = DBF::Table.new(file_path)
      original_contents = dbf_file.map {|r| r.to_a }
      dbf_file.close

      dbf_reader = ETL::DbfReader.open(file_path)
      dbf_reader.contents.should == original_contents
    end

  end

  describe "database loader compatibility - must work like Roo objects" do
    let(:dbf_reader) { ETL::DbfReader.open("/usr/local/htdocs/access/spec/data/TEST_EMPTY.DBF") }


    it "should have dummy 'sheet' functionality" do
      dbf_reader.sheets[0].should_not be_nil
      dbf_reader.default_sheet.should be_nil

      dbf_reader.default_sheet = dbf_reader.sheets[0]
      dbf_reader.default_sheet.should == dbf_reader.sheets[0]
    end

    it "should allow row-by-row reading, with the header row residing at index = 1" do
      dbf_reader.row(1).should == dbf_reader.columns
      dbf_reader.row(2).should == dbf_reader.contents[0]
      dbf_reader.row(dbf_reader.last_row).should == dbf_reader.contents.last
      dbf_reader.last_row.should == dbf_reader.contents.length + 1
    end
  end




  it "should close and get rid of temporary file when dbf reader is closed" do
    file_path = "/usr/local/htdocs/access/spec/data/TEST_EMPTY.DBF"
    dbf_reader = ETL::DbfReader.open(file_path)
    dbf_reader.temp_dbf_file.path.should_not be_nil

    dbf_reader.close
    dbf_reader.temp_dbf_file.path.should be_nil

  end

end