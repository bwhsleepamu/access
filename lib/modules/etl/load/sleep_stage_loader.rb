module ETL
  class SleepStageLoader
    EVENT_NAME = 'scored_epoch'
    FILE_PATTERN = "Slp.01.csv"
    SOURCE_DESCRIPTION = "Scored sleep file compiled by Elizabeth Klerman. For more information, see related source type."
    # @@source_type_name = "<SUBJECT_CODE>Slp.01.csv"
    # @@user_email = "pmankowski@partners.org"
    # @@doc_title = "Loading of Sleep Stage Information"
    # @@event_name = "scored_epoch"

    # @@xls_file_pattern = "Sleep.xls"
    # @@csv_file_pattern = "Slp.01.csv"


    def initialize(root_path, subject_group, source_type, documentation, user)
      LOAD_LOG.info "# Initializing Sleep Stage Loader for subject group #{subject_group.name}"

      event_record = EventDictionary.includes(:data_dictionary => :data_type).find_by_name(EVENT_NAME)
      raise StandardError, "Cannot find record in event dictionary: #{EVENT_NAME}" unless event_record.present?

      @subject_group = subject_group
      @init_subject_list = []
      failed_subject_list = []

      @subject_group.each do |subject|


        begin
          raise StandardError, "Admit year missing for subject #{subject.subject_code}!" unless subject.admit_year.present?

          input_file_path = find_input_file(root_path, subject)

          source = Source.find_or_create_by(location: input_file_path)
          source.update_attributes(source_type_id: source_type.id, description: SOURCE_DESCRIPTION, subject_id: subject.id, documentation_id: documentation.id, user_id: user.id )

          data_info = {
            path: source.location,
            skip_lines: 0
          }

          db_loader = ETL::DatabaseLoader.new(data_info, object_map(subject), column_map, source, documentation, subject)

          @init_subject_list << {subject: subject, loader: db_loader}
        rescue => error
          LOAD_LOG.error "## Failed to initialize subject #{subject.subject_code}"
          LOAD_LOG.info "## Error: #{error.message}\n## Backtrace:\n#{error.backtrace}\n\n"

          failed_subject_list << subject.subject_code
        end

        LOAD_LOG.info "Finished initializing Sleep Stage Loader\n\nSubjects successfully initialized:\n#{@init_subject_list.map{|s| s[:subject].subject_code}}\n\nSubjects failing to initialize: #{failed_subject_list}"

      end
    end

    def load
      loaded_subjects = []
      failed_subjects = []

      LOAD_LOG.info "# Starting to load subjects for subject group #{@subject_group.name}"

      @init_subject_list.each do |subject_info|
        begin
          LOAD_LOG.info "## Loading subject #{subject_info[:subject].subject_code}"
          if subject_info[:loader].load_data
            loaded_subjects << subject_info[:subject].subject_code
          else
            raise StandardError, "Loading of subject #{subject_info[:subject].subject_code} failed!"
          end
        rescue => error
          failed_subjects << subject_info[:subject].subject_code
          LOAD_LOG.info "## Sleep Stage Loading Error for subject #{subject_info[:subject].subject_code}!\n#{error.message}\nBacktrace:\n#{error.backtrace}\n\n"
        end
      end
    end
 
    private

    def column_map
      [
        {
            target: :subject,
            field: :subject_code,
            definitive: true
        },
        {
            target: :datum,
            event_name: EVENT_NAME,
            field: :sleep_wake_period
        },
        {
            target: :event,
            event_name: EVENT_NAME,
            field: :labtime_decimal
        },
        {
            target: :datum,
            event_name: EVENT_NAME,
            field: :scored_stage
        }
      ]
    end

    def object_map(subject)
      [
          {
              class: Subject,
              existing_records: { action: :ignore, find_by: [:subject_code] }
          },
          {
              class: Event,
              event_name: EVENT_NAME,
              existing_records: { action: :append},
              static_fields: { labtime_year: subject.admit_year },
              static_data_fields: { epoch_length: 30 }
          }
      ]
    end

    def find_input_file(path, subject)
      perspective_path = File.join(path, subject.subject_code, "Sleep", "#{subject.subject_code}#{FILE_PATTERN}")

      if File.exists?(perspective_path)
        perspective_path
      else
        raise StandardError, "Could not find sleep file for subject #{subject.subject_code}. Looked in: #{perspective_path}"
      end
    end
  end
end

