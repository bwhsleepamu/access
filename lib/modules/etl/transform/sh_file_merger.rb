require 'find'

module ETL
  class ShFileMerger
    attr_reader :source_directory, :subject_group, :output_directory, :sp_output_name, :lt_output_name

    DEFAULT_SP_NAME = 'sleep_periods.csv'
    DEFAULT_LT_NAME = 'light_events.csv'
    DEFAULT_LT_TYPE = 'LT<lux value>.S~H'
    DEFAULT_SP_TYPE = 'IBOB.S~H'
    DEFAULT_OUTPUT_TYPE = 'Comma Delimited File'

    def initialize(attrs)
      @source_directory = attrs[:source_dir]
      @output_directory = attrs[:output_dir]
      @subject_group = attrs[:subject_group]
      @sp_output_name = attrs[:sp_output_name] || "#{@subject_group.name}_#{DEFAULT_SP_NAME}"
      @lt_output_name = attrs[:lt_output_name] || "#{@subject_group.name}_#{DEFAULT_LT_NAME}"
      @sp_type = SourceType.find_by_name(DEFAULT_SP_TYPE)
      @lt_type = SourceType.find_by_name(DEFAULT_LT_TYPE)
      @output_type = SourceType.find_by_name(DEFAULT_OUTPUT_TYPE)
      @user = User.find_by_email(attrs[:user_email])

      LOAD_LOG.info "Initialized S~H File Merger with the following options:\nsd: #{@source_directory} | od: #{@output_directory} | sg: #{@subject_group.name} | spon: #{@sp_output_name} | lton: #{@lt_output_name} | sptype: #{@sp_type} | lttype: #{@lt_type} | otype: #{@output_type}"
    end

    def merge
      sp_output_path = File.join(output_directory, @sp_output_name)
      lt_output_path = File.join(output_directory, @lt_output_name)

      LOAD_LOG.info "Creating Output Files:\n#{sp_output_path}\n#{lt_output_path}"

      ibob_output = CSV.open(sp_output_path, 'w')
      lt_output = CSV.open(lt_output_path, 'w')

      ibob_source = Source.new(location: sp_output_path, user: @user, source_type_id: @output_type.id)
      lt_source = Source.new(location: sp_output_path, user: @user, source_type_id: @output_type.id)

      ibob_output << ['subject_code', 'sleep_period_number', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']
      lt_output << ['subject_code', 'light_level', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']

      successful = []
      unsuccessful = []

      subject_group.subjects.each do |subject|
        begin
          subject_dir = ETL::TDriveCrawler.find_subject_directory(subject, @source_directory)

          unless File.directory? subject_dir
            raise StandardError, "Cannot find subject directory #{subject_dir} for subject #{subject.subject_code}"
          end

          Find.find(subject_dir) do |path|
            if path =~ /.*ibob.*\.s~h$/i
              merge_ibob(subject, path, ibob_output, ibob_source)
            elsif path =~ /.*lt(\d+).*\.s~h$/i
              merge_lt(subject, path, $1, lt_output, lt_source)
            end
          end

          successful << subject.subject_code
        rescue => error
          LOAD_LOG.info "## Sh File Merger: #{error.message}\nBacktrace:\n#{error.backtrace}"
          unsuccessful << subject.subject_code
        end
      end

      ibob_output.close
      lt_output.close
      ibob_source.save && lt_source.save

    end



    def merge_ibob(subject, path, output, source)
      source.child_sources.build(location: path, user: @user, source_type_id: @sp_type)
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

    def merge_lt(subject, path, lux, output, source)
      source.child_sources.build(location: path, user: @user, source_type_id: @lt_type)
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