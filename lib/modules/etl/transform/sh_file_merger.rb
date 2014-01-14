require 'find'

module ETL
  class ShFileMerger
    attr_reader :source_directory, :subject_group, :output_directory, :sp_output_name, :lt_output_name, :cr_output_name

    DEFAULT_SP_NAME = 'sleep_periods.csv'
    DEFAULT_LT_NAME = 'light_events.csv'
    DEFAULT_CR_NAME = 'constant_routines.csv'
    DEFAULT_LT_TYPE = 'LT<lux value>.S~H'
    DEFAULT_SP_TYPE = 'IBOB.S~H'
    DEFAULT_CR_TYPE = 'CR.S~H'
    DEFAULT_OUTPUT_TYPE = 'Comma Delimited File'
    SH_LINE_REGEX = /(\d\d\d\d)\s+(\d{4,})\:(\d\d)\,\s*(\d{4,})\:(\d\d)/i

    def initialize(attrs)
      @source_directory = attrs[:source_dir]
      @output_directory = attrs[:output_dir]
      @subject_group = attrs[:subject_group]
      @sp_output_name = attrs[:sp_output_name] || "#{@subject_group.name}_#{DEFAULT_SP_NAME}"
      @lt_output_name = attrs[:lt_output_name] || "#{@subject_group.name}_#{DEFAULT_LT_NAME}"
      @cr_output_name = attrs[:cr_output_name] || "#{@subject_group.name}_#{DEFAULT_CR_NAME}"

      @sp_type = SourceType.find_by_name(DEFAULT_SP_TYPE)
      @lt_type = SourceType.find_by_name(DEFAULT_LT_TYPE)
      @cr_type = SourceType.find_by_name(DEFAULT_CR_TYPE)
      @output_type = SourceType.find_by_name(DEFAULT_OUTPUT_TYPE)
      @user = User.find_by_email(attrs[:user_email])

      @find_missing_t_drive_location = attrs[:find_missing_t_drive_location]
      @find_missing_t_drive_location ||= false

      LOAD_LOG.info "Initializing S~H File Merger with the following options:\nsd: #{@source_directory} | od: #{@output_directory} | sg: #{@subject_group.name} | spon: #{@sp_output_name} | lton: #{@lt_output_name} | cron: #{@cr_output_name} | sptype: #{@sp_type} | lttype: #{@lt_type} | crtype: #{@cr_type} | otype: #{@output_type} | user: #{@user}"
      raise StandardError, "Failed to initialize!\n#{@source_directory} && #{@output_directory} && #{@subject_group} && #{@sp_type} && #{@lt_type} && #{@cr_type} && #{@output_type} && #{@user}" unless (@source_directory && @output_directory && @subject_group && @sp_type && @lt_type && @cr_type && @output_type && @user)
    end

    def merge
      sp_output_path = File.join(output_directory, @sp_output_name)
      lt_output_path = File.join(output_directory, @lt_output_name)
      cr_output_path = File.join(output_directory, @cr_output_name)

      LOAD_LOG.info "Creating Output Files:\n#{sp_output_path}\n#{lt_output_path}\n#{cr_output_path}"

      ibob_output = CSV.open(sp_output_path, 'w')
      lt_output = CSV.open(lt_output_path, 'w')
      cr_output = CSV.open(cr_output_path, 'w')

      ibob_source = Source.new(location: sp_output_path, user: @user, source_type: @output_type)
      lt_source = Source.new(location: lt_output_path, user: @user, source_type: @output_type)
      cr_source = Source.new(location: cr_output_path, user: @user, source_type: @output_type)

      ibob_output << ['subject_code', 'sleep_period_number', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']
      lt_output << ['subject_code', 'light_level', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']
      cr_output << ['subject_code', 'constant_routine_number', 'start_labtime_hour', 'start_labtime_min', 'start_labtime_year', 'end_labtime_hour', 'end_labtime_min', 'end_labtime_year']

      successful = []
      unsuccessful = []

      subject_group.subjects.each do |subject|
        begin
          subject_dir = ETL::TDriveCrawler.find_subject_directory(subject, @source_directory, @find_missing_t_drive_location)

          unless subject_dir && File.directory?(subject_dir)
            raise StandardError, "Cannot find subject directory #{subject_dir} for subject #{subject.subject_code}"
          end

          file_lists = {ibob: [], lt: {}, cr: []}

          Find.find(subject_dir) do |path|
            if path =~ /.*ibob.*\.s~h$/i
              file_lists[:ibob] << path
            elsif path =~ /.*lt(\d+).*\.s~h$/i
              file_lists[:lt][$1] ||= []
              file_lists[:lt][$1] << path
            elsif path =~ /.*cr.*\.s~h$/i
              file_lists[:cr] << path
            end
          end

          if file_lists[:ibob].length == 1
            merge_ibob(subject, file_lists[:ibob].first, ibob_output, ibob_source)
          else
            raise StandardError, "#{file_lists[:ibob].length} IBOB files found in subject folder!\nsubject: #{subject.subject_code} | dir: #{subject_dir}\npaths: #{file_lists[:ibob]}"
          end

          if file_lists[:cr].length == 1
            merge_cr(subject, file_lists[:cr].first, cr_output, cr_source)
          else
            raise StandardError, "#{file_lists[:cr].length} CR files found in subject folder!\nsubject: #{subject.subject_code} | dir: #{subject_dir}\npaths: #{file_lists[:cr]}"
          end

          file_lists[:lt].each_pair do |lux_val, paths|
            if paths.length == 1
              merge_lt(subject, paths.first, lux_val, lt_output, lt_source)
            else
              raise StandardError, "#{paths.length} LT #{lux_val} files found in subject folder!\nsubject: #{subject.subject_code} | dir: #{subject_dir}\npaths: #{paths}"
            end
          end

          successful << subject.subject_code
        rescue => error
          LOAD_LOG.info "\n####\nERROR! #{subject.subject_code} Sh File Merger: #{error.message} | Backtrace:\n#{error.backtrace}\n####"
          unsuccessful << subject.subject_code
        end
      end

      ibob_output.close
      lt_output.close
      cr_output.close

      LOAD_LOG.info "#{successful.length} successful subjects: #{successful}"
      LOAD_LOG.info "#{unsuccessful.length} unsuccessful subjects: #{unsuccessful}"

      ibob_source.save && lt_source.save && cr_source.save
    end



    def merge_ibob(subject, path, output, source)
      source.child_sources.build(location: path, user: @user, source_type: @sp_type, subject: subject)
      File.open(path).each_line do |line|
        begin
          m = SH_LINE_REGEX.match(line)
          raise StandardError, "Invalid row: |#{line}| in: #{path}" unless m
          output << [subject.subject_code, m[1].to_i, m[2].to_i, m[3].to_i, subject.admit_year, m[4].to_i, m[5].to_i, subject.admit_year]
        rescue => error
          MY_LOG.info "\n#### ERROR! Sh File Merger (IBOB):\n#{error.message}####\n"
        end
      end
    end


    def merge_cr(subject, path, output, source)
      source.child_sources.build(location: path, user: @user, source_type: @cr_type, subject: subject)
      File.open(path).each_line do |line|
        begin
          m = SH_LINE_REGEX.match(line)
          raise StandardError, "Invalid row: #{line} in: #{path}" unless m
          output << [subject.subject_code, m[1].to_i, m[2].to_i, m[3].to_i, subject.admit_year, m[4].to_i, m[5].to_i, subject.admit_year]
        rescue => error
          MY_LOG.info "\n#### ERROR! Sh File Merger (CR):\n#{error.message}####\n"
        end
      end
    end

    def merge_lt(subject, path, lux, output, source)
      source.child_sources.build(location: path, user: @user, source_type: @lt_type, subject: subject)
      File.open(path).each_line do |line|
        begin
          m = SH_LINE_REGEX.match(line)
          raise StandardError, "Invalid row: #{line} in: #{path}" unless m
          output << [subject.subject_code, lux, m[2].to_i, m[3].to_i, subject.admit_year, m[4].to_i, m[5].to_i, subject.admit_year]
        rescue => error
          MY_LOG.info "\n#### ERROR! Sh File Merger (LT):\n#{error.message}####\n"
        end
      end
    end
  end

end