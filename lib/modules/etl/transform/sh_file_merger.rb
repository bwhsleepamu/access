require 'find'

module ETL
  class ShFileMerger
    attr_reader :source_directory, :subject_group, :output_directory

    def initialize(source_directory, output_directory, subject_group)
      @source_directory = source_directory
      @output_directory = output_directory
      @subject_group = subject_group
    end

    def merge
      ibob_output = CSV.open(File.join(output_directory, "sleep_periods.csv"), 'w')
      lt_output = CSV.open(File.join(output_directory, "light_events.csv"), 'w')

      ibob_output << ['subject_code', 'sleep_period_number', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']
      lt_output << ['subject_code', 'light_level', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']

      successful = []
      unsuccessful = []

      subject_group.subjects.each do |subject|
        begin
          subject_dir = File.join(source_directory, subject.subject_code)
          subject_dir = File.join(source_directory, subject.subject_code.downcase) unless File.directory? subject_dir

          unless File.directory? subject_dir
            raise StandardError, "Cannot find subject directory #{subject_dir} for subject #{subject.subject_code}"
          end

          Find.find(subject_dir) do |path|
            if path =~ /.*ibob.*\.s~h$/i
              merge_ibob(subject, path, ibob_output)
            elsif path =~ /.*lt(\d+).*\.s~h$/i
              merge_lt(subject, path, $1, lt_output)
            end
          end

          successful << subject.subject_code
        rescue => error
          LOAD_LOG.info "## Sh File Merger: #{error.message}\nBacktrace:\n#{error.backtrace}"
          unsuccessful << subject.subject_code
        end
      end
    end



    def merge_ibob(subject, path, output)
      File.open(path).each_line do |line|
        begin
          m = /(\d\d\d\d) (\d\d\d\d\d)\:(\d\d)\,(\d\d\d\d\d)\:(\d\d)/i.match(line)
          raise StandardError, "Invalid row: #{line}" unless m
          output << [subject.subject_code, m[1].to_i, m[2].to_i, m[3].to_i, subject.admit_year, m[4].to_i, m[5].to_i, subject.admit_year]
        rescue => error
          LOAD_LOG.info "## Sh File Merger: #{error.message}\nRow: #{line}\nBacktrace:\n#{error.backtrace}"
        end
      end
    end

    def merge_lt(subject, path, lux, output)
      File.open(path).each_line do |line|
        begin
          m = /(\d\d\d\d) (\d\d\d\d\d)\:(\d\d)\,(\d\d\d\d\d)\:(\d\d)/i.match(line)
          raise StandardError, "Invalid row: #{line}" unless m
          output << [subject.subject_code, lux, m[2].to_i, m[3].to_i, subject.admit_year, m[4].to_i, m[5].to_i, subject.admit_year]
        rescue => error
          LOAD_LOG.info "## Sh File Merger: #{error.message}\nRow: #{line}\nBacktrace:\n#{error.backtrace}"
        end
      end
    end
  end

end