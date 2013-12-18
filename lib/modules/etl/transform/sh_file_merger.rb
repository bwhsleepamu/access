require 'find'

module ETL
  ## Overview
  # This class will allow the merging of PSQ data into a single spreadsheet that can be loaded using the PSQ Loader.
  # Two types of PSQ source files will be dealt with: Jeanne Duffy's and Elizabeth Klerman's
  # Two merged files will be made as a result.
  # Documentation: 10141 (Jeane Duffy)
  ##





  class ShFileMerger
    attr_reader :source_directory, :subject_group
    #IBOB.S~H
    #LTXX.S~H

    def initialize(source_directory, output_file, subject_group)
      @source_directory = source_directory
      @subject_group = subject_group
    end

    def merge
      successful = []
      unsuccessful = []

      subject_group.each do |subject|
        begin
          subject_dir = File.join(source_directory, subject.subject_code)
          subject_dir = File.join(source_directory, subject.subject_code.downcase) unless File.directory? subject_dir

          unless File.directory? subject_dir
            raise StandardError, "Cannot find subject directory #{subject_dir} for subject #{subject.subject_code}"
          end

          Find.find(subject_dir) do |path|
            
          end


        rescue => error
          LOAD_LOG.info "## Sh File Merger: #{error.message}\nBacktrace:\n#{error.backtrace}"
          unsuccessful << subject.subject_code
        end
      end
    end

  end
end