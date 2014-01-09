module ETL
  class CrDataLoader
    def initialize(source, documentation)
      begin
        input_file_info = { path: source.location, skip_lines: 1 }
        @db_loader = ETL::DatabaseLoader.new(input_file_info, object_map, column_map, source, documentation)

        LOAD_LOG.info "#### CR Data Loader: Successfully initialized for loading of Sleep data"
        @valid = true
      rescue => error
        LOAD_LOG.info "#### CR Data Loader Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
        @valid = false
      end
    end

    def valid?
      @valid
    end

    def load
      if @valid
        loaded = false
        begin
          LOAD_LOG.info "######################    CR Data LOADER  #######################"
          LOAD_LOG.info "###################### Starting  #######################"
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
          { target: :subject, field: :subject_code},
          { target: :datum, field: :constant_routine_number, event_name: 'constant_routine_start' },
          { target: :event, field: :labtime_hour, event_name: 'constant_routine_start' },
          { target: :event, field: :labtime_min, event_name: 'constant_routine_start' },
          { target: :event, field: :labtime_year, event_name: 'constant_routine_start' },
          { target: :event, field: :labtime_hour, event_name: 'constant_routine_end' },
          { target: :event, field: :labtime_min, event_name: 'constant_routine_end' },
          { target: :event, field: :labtime_year, event_name: 'constant_routine_end' }
      ]
    end

    def object_map
      [
          {
              class: Subject,
              existing_records: {action: :ignore, find_by: [:subject_code]}
          },
          {
              class: Event,
              existing_records: {action: :append },
              event_name: 'constant_routine_start',
              group: :sleep_period,
              static_fields: { labtime_sec: 0 }
          },
          {
              class: Event,
              existing_records: { action: :append },
              event_name: 'constant_routine_end',
              group: :sleep_period,
              static_fields: { labtime_sec: 0 }
          }
      ]
    end

  end
end







