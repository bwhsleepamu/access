=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end




module ETL
  class PsqLoader
    EVENT_NAME = 'post_sleep_questionnaire'



    def initialize(source, documentation)
      begin
        data_info = { path: source.location, skip_lines: 1, header: true }

        init_column_map
        init_object_map

        @db_loader = ETL::DatabaseLoader.new(data_info, @object_map, @column_map, source, documentation)
      rescue => error
        LOAD_LOG.info "#### Setup Error: #{error.message}\n\nBacktrace:\n#{error.backtrace}"
      end
    end





    private
#    subject_code	sleep_period	lights_out_labtime_decimal	q_1	q_2	q_3	q_4	q_4a	q_5	q_6	q_7	q_8	notes

    def init_column_map
      @column_map = [
          { target: :subject, field: :subject_code },
          { target: :datum, field: :sleep_period, event_name: EVENT_NAME },
          { target: :event, field: :labtime_decimal },
          { target: :event, field: :labtime_year },
          { target: :none },
          { target: :none },
          { target: :none },
          { target: :datum, field: :question_1, event_name: EVENT_NAME },
          { target: :datum, field: :question_2, event_name: EVENT_NAME },
          { target: :datum, field: :question_3, event_name: EVENT_NAME },
          { target: :datum, field: :question_4, event_name: EVENT_NAME },
          { target: :datum, field: :question_4a, event_name: EVENT_NAME },
          { target: :datum, field: :question_5, event_name: EVENT_NAME },
          { target: :datum, field: :question_6, event_name: EVENT_NAME },
          { target: :datum, field: :question_7, event_name: EVENT_NAME },
          { target: :datum, field: :question_8, event_name: EVENT_NAME },
          { target: :event, field: :notes, event_name: EVENT_NAME }
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
