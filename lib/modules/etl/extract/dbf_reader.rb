require 'dbf'

module ETL
  class DbfReader
    # CLEAN_DBF_DIR = "/home/pwm4/Windows/idrive/Projects/Database Project/Data Sources/T_DRIVE/Clean DBF"

    attr_reader :dbf, :columns, :contents, :temp_dbf_file, :file_path
    attr_accessor :default_sheet

    def self.open(file_path)
      dr = ETL::DbfReader.new(file_path)
      dr
    end

    def self.copy(file_path, new_file_path)
      create_clean_dbf(file_path, new_file_path)
    end

    def initialize(file_path)
      # create temp file with 'deleted' marker removed
      @temp_dbf_file = Tempfile.new("DBF")
      ETL::DbfReader.create_clean_dbf(file_path, @temp_dbf_file)

      # Set up DBF Table
      @dbf = DBF::Table.new(@temp_dbf_file)
      @columns = @dbf.columns.map {|c| c.name}
      @contents = @dbf.map {|r| r.to_a}
      @file_path = file_path
    end

    def row(index)
      if index == 1
        @columns
      else
        @contents[index - 2]
      end
    end

    def row_index(column_name)
      @columns.index(column_name)
    end

    def sheets
      ["default"]
    end

    def last_row
      1 + @contents.length
    end

    def length
      @contents.length
    end


    def path
      @file_path
    end

    def filename
      @file_path
    end

    def close
      @dbf.close
      @temp_dbf_file.close
      @temp_dbf_file.unlink
    end


    private

    def self.create_clean_dbf(dbf_file_path, new_file)
      # Gets rid of 'deleted' marker that hides records in many of the dbf files on the T Drive



      file_size = File.size(dbf_file_path)
      mem_buffer = IO.binread(dbf_file_path, file_size, 0)

      content_array = mem_buffer.unpack('C*')
      content_array = content_array.map do |x|
        # Get rid of asterixes (dec code == 42) and replace with spaces (dec code == 32)
        x == 42 ? 32 : x
      end

      content_string = content_array.pack('C*')
      IO.binwrite(new_file, content_string)
    end

  end
end