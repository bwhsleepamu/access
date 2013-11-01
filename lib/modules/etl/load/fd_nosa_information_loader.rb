module ETL
  class FdNosaInformationLoader

    def initialize(source_path, source, documentation)
      begin               
        @data_info = { path: source_path, skip_lines: 1, header: true, sheet: "Analyses", empty_cell_markers: ['.'] }
        init_column_map
        init_object_map

        @db_loader = ETL::DatabaseLoader.new(@data_info, @object_map, @column_map, source, documentation)
      rescue => error
        LOAD_LOG.info "#### Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
      end
    end

    def load
      LOAD_LOG.info "###################### Starting to load #{@data_info[:path]} #######################"
      loaded = false
      begin
        loaded = @db_loader.load_data
      rescue => error
        LOAD_LOG.info "#### Load Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}\n\n"
      end
      loaded
    end
 
    private

    def init_column_map
      @column_map = [
        { target: :subject, field: :subject_code },
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :event, field: :notes, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :unit_of_measure, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :tau, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :circadian_amplitude, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :t_cycle_amplitude, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :composite_maximum, event_name: :nosa_analysis_melatonin },
        { target: :datum, field: :fundamental_maximum, event_name: :nosa_analysis_melatonin },
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :none},
        { target: :datum, field: :tau, event_name: :phase_analysis_cbt },
        { target: :datum, field: :circadian_amplitude, event_name: :phase_analysis_cbt },
        { target: :datum, field: :t_cycle_amplitude, event_name: :phase_analysis_cbt },
        { target: :datum, field: :composite_maximum, event_name: :phase_analysis_cbt },
        { target: :datum, field: :fundamental_maximum, event_name: :phase_analysis_cbt },
      ]
    end

    def init_object_map
      @object_map = [
          {
              class: Subject,
              existing_records: {action: :ignore, find_by: [:subject_code]}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: :nosa_analysis_melatonin,
              static_fields: {realtime: Time.zone.now}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: :phase_analysis_cbt,
              static_fields: {realtime: Time.zone.now}
          }
      ]
    end

  end
end

