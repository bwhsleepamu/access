module ETL
  class SleepDataLoader
    SOURCE_SHEET = "Sleep Episodes"

    def initialize(subject, source, documentation)

      begin
        @subject = subject
        admit_year = find_admit_year(subject, source)
        input_file_info = { path: source.location, sheet: SOURCE_SHEET, skip_lines: 1 }

        @db_loader = ETL::DatabaseLoader.new(input_file_info, object_map(admit_year), column_map, source, documentation, @subject)
        LOAD_LOG.info "#### Sleep Data Loader: Successfully initialized #{@subject.subject_code} for loading of Sleep data"
        @valid = true
      rescue => error
        LOAD_LOG.info "#### Sleep Data Loader: #{@subject.subject_code} Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
        @valid = false
      end
    end

    def valid?
      @valid
    end

    def load_subject
      if @valid
        loaded = false
        begin
          LOAD_LOG.info "######################    SleeP Data LOADER: #{@main_event_name}     #######################"
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
          { target: :datum, field: :period_number, event_name: 'sleep_period_start' },
          { target: :event, field: :labtime_decimal, event_name: 'sleep_period_start' },
          { target: :event, field: :labtime_decimal, event_name: 'sleep_period_end' }
      ]
    end

    def object_map(patient_year)
      [
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: 'sleep_period_start',
              group: :sleep_period,
              static_fields: { labtime_year: patient_year }
          },
          {
              class: Event,
              existing_records: { action: :destroy, find_by: [:name, :subject_id]},
              event_name: 'sleep_period_end',
              group: :sleep_period,
              static_fields: { labtime_year: patient_year }
          }
      ]
    end

    def find_admit_year(subject, source)
      if subject.admit_year.present?
        subject.admit_year
      else
        MY_LOG.info source.location
        xls = Roo::Excel.new(source.location)
        m = /.*_\d\d\d\d(\d\d)_.*/.match xls.sheet("manfiles").row(4)[0]
        if m
          year = m[1].to_i
          year += (year > 50 ? 1900 : 2000)
          year
        else
          raise StandardError, "No Admit Year Found for #{subject.subject_code}" unless year
        end


      end
    end

  end
end







