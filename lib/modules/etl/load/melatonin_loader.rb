=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end




module ETL
  class MelatoninLoader
    EVENT_NAME = 'melatonin_sample'

    def initialize(subject, source, documentation)
      begin
        data_info = { path: source.location, skip_lines: 1, header: true }

        init_column_map
        init_object_map

        @db_loader = ETL::DatabaseLoader.new(data_info, @object_map, @column_map, source, documentation, subject)
      rescue => error
        LOAD_LOG.info "#### Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
      end
    end

    private
#    subject_code	sleep_period	lights_out_labtime_decimal	q_1	q_2	q_3	q_4	q_4a	q_5	q_6	q_7	q_8	notes

    def init_column_map
      @column_map = [
          { target: :subject, field: :subject_code },
          { target: :event, field: :labtime },
          { target: :datum, field: :sample_number, event_name: EVENT_NAME },
          { target: :none },
          { target: :none },
          { target: :datum, field: :concentration_pg_ml, event_name: EVENT_NAME },
          { target: :datum, field: :concentration_pmol_l, event_name: EVENT_NAME },
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
              event_name: EVENT_NAME,
              existing_records: { action: :destroy, find_by: [:name, :subject_id]}
          }
      ]
    end
  end
end
