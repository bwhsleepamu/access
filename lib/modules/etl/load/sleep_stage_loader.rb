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
      event_record = EventDictionary.includes(:data_dictionary => :data_type).find_by_name(EVENT_NAME)
      raise StandardError, "Cannot find record in event dictionary: #{EVENT_NAME}" unless event_record.present?

      @subject_list = []

      subject_group.each do |subject|


        begin
          raise StandardError, "Admit year missing for subject #{subject.subject_code}!" unless subject.admit_year.present?

          input_file_path = find_input_file(root_path, subject)

          source = Source.find_or_create_by(location: input_file_path)
          source.update_attributes(source_type_id: source_type.id, description: SOURCE_DESCRIPTION, subject_id: subject.id, documentation_id: documentation.id, user_id: user.id )

          data_info = {
            path: source.location,
            skip_lines: 0
          }
        end

      end




      begin
        #xls_file_name = "#{subject_code}#{@@xls_file_pattern}"

        # csv_file_name = "#{subject_code}#{@@csv_file_pattern}"

        (@subject = Subject.find_by(subject_code: subject_code))

        patient_year = get_year(File.join(parent_path, subject_code, "Sleep", xls_file_name))

        source_type = SourceType.find_by_name(@@source_type_name)
        user = User.find_by_email(@@user_email)
        documentation = Documentation.find_by_title(@@doc_title)
        event_dictionary = EventDictionary.includes(:data_dictionary => :data_type).find_by_name(@@event_name)
        source = Source.create(
          source_type_id: source_type.id, 
          user_id: user.id, 
          location: File.join(general_path, subject_code, "Sleep", csv_file_name), 
          notes: "Year taken from #{subject_code}Sleep.xls file." 
        )

        data_info = {
          path: File.join(parent_path, subject_code, "Sleep", csv_file_name),
          skip_lines: 0
        }

        column_map = [
          {
            target: :subject,
            field: :subject_code,
            definitive: true
          },
          {
            target: :datum,
            event_name: @@event_name,
            field: :sleep_wake_period
          },
          {
            target: :event,
            event_name: @@event_name,
            field: :labtime_decimal
          },
          {
            target: :datum,
            event_name: @@event_name,
            field: :scored_stage
          }
        ]

        object_map =

        @db_loader = ETL::DatabaseLoader.new(data_info, object_map, column_map, source, documentation, @subject)
        LOAD_LOG.info "#### Successfully initialized #{@subject.subject_code} for loading of sleep stage data."

        @valid = true
      rescue => error
        LOAD_LOG.info "#### Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
        @valid = false
      end
    end

    def load_subject
      if @valid and Event.current.where(subject_id: @subject.id, name: 'scored_epoch').count == 0
        loaded = false
        begin
          LOAD_LOG.info "###################### Starting #{@subject.subject_code} #######################"
          loaded = @db_loader.load_data
        rescue => error
          LOAD_LOG.info "#### Load Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}\n\n"
        end
        loaded
      else
        false
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

    def get_year(path)
      if @subject.admit_date.present?
        @subject.admit_date.year
      else

        raise StandardError, "Could not find year!"
        # xx = Roo::Excel.new(path)
        # xx.default_sheet = xx.sheets[0]
        #
        # #xx.default_sheet = "tasciifiles"
        #
        # row_count = 2
        # until (m = /.*_*.(\d\d)_.*/i.match(xx.row(row_count)[0])).present? or row_count > 100
        #   row_count += 1
        # end
        #
        # raise StandardError, "Could not find suitable year from excel file!" if row_count > 100
        #
        # year = m[1].to_i
        # year + ((year < 60) ? 2000 : 1900)
      end
    end

  end
end

