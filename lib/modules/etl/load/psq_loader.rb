=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end




module ETL
  class PsqLoader
    EVENT_NAME = 'post_sleep_questionnaire'



    def initialize(subject_group, source, documentation)


    end





    private
#    subject_code	sleep_period	lights_out_labtime_decimal	q_1	q_2	q_3	q_4	q_4a	q_5	q_6	q_7	q_8	notes

    def init_column_map
      @column_map = [
          { target: :subject, field: :subject_code },
          { target: :datum, field: :sleep_period },
          { target: :datum, field: :lights_out_labtime_decimal },
          { target: :datum, field: :question_1 },
          { target: :datum, field: :question_2 },
          { target: :datum, field: :question_3 },
          { target: :datum, field: :question_4 },
          { target: :datum, field: :question_4a },
          { target: :datum, field: :question_5 },
          { target: :datum, field: :question_6 },
          { target: :datum, field: :question_7 },
          { target: :datum, field: :question_8 },
          { target: :event, field: :notes }
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
