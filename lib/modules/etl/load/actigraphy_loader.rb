module ETL
  class ActigraphyLoader
    SOURCE_TYPE_NAME = "Comma Delimited File"
    USER_EMAIL = "pmankowski@partners.org"
    DOC_TITLE = "Loading of Actigraphy Data"
    EVENT_NAME = "actigraphy_measurement"

    CSV_FILE_PATTERN = ".csv"
    NOTES_FILE_PATTERN = "_notes.txt"

    def initialize(subject_code, parent_path, general_path, overwrite = false)
      begin
        @overwrite = overwrite

        csv_file_name = "#{subject_code}#{CSV_FILE_PATTERN}"
        notes_file_name = "#{subject_code}#{NOTES_FILE_PATTERN}"

        @subject = Subject.find_or_create_by(subject_code: subject_code)
        
        source_type = SourceType.find_by_name(SOURCE_TYPE_NAME)
        user = User.find_by_email(USER_EMAIL)
        documentation = Documentation.find_by_title(DOC_TITLE)

        event_dictionary = EventDictionary.includes(:data_dictionary => :data_type).find_by_name(EVENT_NAME)
        source_notes = get_source_notes(File.join(parent_path, notes_file_name))

        source_location = File.join(general_path, csv_file_name)
        source = Source.find_by_location(source_location)

        source ||= Source.create(
          source_type_id: source_type.id, 
          user_id: user.id, 
          location: source_location,
          notes: source_notes
        )

        data_info = {
          path: File.join(parent_path, csv_file_name),
          skip_lines: 1
        }

        column_map = [
          { target: :none },
          { target: :none },
          { target: :event, field: :labtime_year, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_hour, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_min, event_name: EVENT_NAME.to_sym },
          { target: :event, field: :labtime_sec, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :activity_count, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :light_level, event_name: EVENT_NAME.to_sym },
          { target: :datum, field: :epoch_length, event_name: EVENT_NAME.to_sym }
        ]

        object_map = [
          {
            class: Event,
            existing_records: {action: :destroy, find_by: [:name, :subject_id]},
            event_name: EVENT_NAME.to_sym
          }
        ]

        @db_loader = ETL::DatabaseLoader.new(data_info, object_map, column_map, source, documentation, @subject)
      rescue => error
        LOAD_LOG.info "#### Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
      end
    end

    def events_exist?
      @subject.events.where(name: EVENT_NAME).count > 0
    end

    def load_subject
      LOAD_LOG.info "###################### Starting #{@subject.subject_code} #######################"
      loaded = false
      begin
        loaded = @db_loader.load_data if @overwrite or !events_exist?
      rescue => error
        LOAD_LOG.info "#### Load Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}\n\n"
      end
      loaded
    end
 
    private

    def get_source_notes(path)
      notes_file = File.open(path, 'r')
      notes_file.read
    end

  end
end

