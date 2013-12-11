=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end




module ETL
  class VasLoader
    SOURCE_SHEET = "FEV"

    def initialize(subject, source, documentation, base_event_name)
      begin
        @main_event_name = "#{base_event_name}_cleaned"
        @scheduled_event_name = "#{base_event_name}_scheduled"

        @subject = subject
        admit_year = find_admit_year(subject, source)
        input_file_info = { path: source.location, sheet: SOURCE_SHEET, skip_lines: 1 }

        @db_loader = ETL::DatabaseLoader.new(input_file_info, object_map(@main_event_name, @scheduled_event_name, admit_year), column_map(@main_event_name, @scheduled_event_name), source, documentation, @subject)
        LOAD_LOG.info "#### VAS Loader: Successfully initialized #{@subject.subject_code} for loading of Visual Analog Scale data"
        @valid = true
      rescue => error
        LOAD_LOG.info "#### VAS Loader: Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
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
          LOAD_LOG.info "######################      VAS LOADER: #{@main_event_name}     #######################"
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

    def column_map(main_event_name, scheduled_event_name)
      map =
      [
          { target: :event, field: :labtime, event_name: @main_event_name },
          { target: :event, field: :labtime_sec, event_name: @main_event_name },
          { target: :none },
          { target: :none },
          { target: :subject, field: :subject_code },
          { target: :none },
          { target: :none },
          { target: :event, field: :labtime_decimal, event_name: @scheduled_event_name },
          { target: :datum, field: :wake_period, event_name: @main_event_name},
          { target: :datum, field: :section_of_protocol, event_name: @main_event_name},
          { target: :datum, field: :test_type_identifier, event_name: @main_event_name},
          { target: :datum, field: :session_number, event_name: @main_event_name},
      ]

      if main_event_name == 'vas_scalesad_cleaned'
        map +=
            [
                { target: :datum, field: :sleepy_alert, event_name: @main_event_name},
                { target: :datum, field: :excited_calm, event_name: @main_event_name},
                { target: :datum, field: :weak_strong, event_name: @main_event_name},
                { target: :datum, field: :groggy_clearheaded, event_name: @main_event_name},
                { target: :datum, field: :clumsy_wellcoordinated, event_name: @main_event_name},
                { target: :datum, field: :sluggish_energetic, event_name: @main_event_name},
                { target: :datum, field: :discontented_contented, event_name: @main_event_name},
                { target: :datum, field: :troubled_tranquil, event_name: @main_event_name},
                { target: :datum, field: :mentallyslow_quickwitted, event_name: @main_event_name},
                { target: :datum, field: :tense_relaxed, event_name: @main_event_name},
                { target: :datum, field: :dreamy_attentive, event_name: @main_event_name},
                { target: :datum, field: :incompetent_competent, event_name: @main_event_name},
                { target: :datum, field: :happy_sad, event_name: @main_event_name},
                { target: :datum, field: :hostile_friendly, event_name: @main_event_name},
                { target: :datum, field: :bored_interested, event_name: @main_event_name},
                { target: :datum, field: :withdrawn_sociable, event_name: @main_event_name},
                { target: :datum, field: :cold_warm, event_name: @main_event_name},
            ]
      elsif main_event_name == 'vas_shtscale_cleaned'
        map +=
            [
                { target: :datum, field: :sleepy_alert, event_name: @main_event_name},
                { target: :datum, field: :happy_sad, event_name: @main_event_name},
                { target: :datum, field: :excited_calm, event_name: @main_event_name}
            ]
      end

      map += [
              { target: :datum, field: :version, event_name: @main_event_name},
              { target: :event, field: :notes, event_name: @main_event_name}
             ]

      map
    end

    def object_map(main_event_name, scheduled_event_name, patient_year)
      [
          {
              class: Subject,
              existing_records: {action: :ignore, find_by: [:subject_code]}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: main_event_name,
              static_fields: { labtime_year: patient_year }
          },
          {
              class: Event,
              existing_records: { action: :destroy, find_by: [:name, :subject_id]},
              event_name: scheduled_event_name,
              static_fields: { labtime_year: patient_year }
          }
      ]
    end

    def find_admit_year(subject, source)
      if subject.admit_year.present?
        subject.admit_year
      else
        xls = Roo::Spreadsheet.open(source.location)
        m = /\d+\/\d+\/(\d+)/.match xls.sheet("FEV").row(2)[2]
        m[1].to_i
      end
    end

  end
end







