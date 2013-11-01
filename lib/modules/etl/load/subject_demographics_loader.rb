module ETL
  class SubjectDemographicsLoader

    def initialize(source_path, subject_type, source, documentation)
      begin
        @data_info = {path: source_path, skip_lines: 2, header: true}
        init_column_map
        init_object_map

        if subject_type == :forced_desynchrony
          init_fd_subjects
        elsif subject_type == :light
          init_light_subjects
        else
          raise StandardError, "Invalid subject type: #{subject_type}"
        end

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
          {target: :subject, field: :subject_code},
          {target: :datum, field: :suite_number, event_name: :subject_demographics},
          {target: :datum, field: :log_book_number, event_name: :subject_demographics},
          {target: :datum, field: :date_of_birth, event_name: :subject_demographics},
          {target: :datum, field: :age, event_name: :subject_demographics},
          {target: :datum, field: :sex, event_name: :subject_demographics},
          {target: :datum, field: :ethnic_category, event_name: :subject_demographics},
          {target: :datum, field: :race, event_name: :subject_demographics, multiple: true},
          {target: :datum, field: :height, event_name: :subject_demographics},
          {target: :datum, field: :weight, event_name: :subject_demographics},
          {target: :datum, field: :blood_pressure_systolic, event_name: :subject_vitals},
          {target: :datum, field: :blood_pressure_diastolic, event_name: :subject_vitals},
          {target: :datum, field: :heart_rate, event_name: :subject_vitals},
          {target: :datum, field: :habitual_day_off_weekend_bed_time_lower_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_day_off_weekend_bed_time_upper_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_school_work_bed_time_lower_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_school_work_bed_time_upper_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_day_off_weekend_wake_time_lower_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_day_off_weekend_wake_time_upper_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_school_work_wake_time_lower_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :habitual_school_work_wake_time_upper_bound, event_name: :subject_sleep_habits},
          {target: :datum, field: :desired_bedtime, event_name: :subject_sleep_habits},
          {target: :datum, field: :desired_waketime, event_name: :subject_sleep_habits},
          {target: :datum, field: :owl_lark_score, event_name: :subject_demographics},
          {target: :event, field: :notes, event_name: :subject_demographics},
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
              event_name: :subject_demographics,
              static_fields: {realtime: Time.zone.now}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: :subject_vitals,
              static_fields: {realtime: Time.zone.now}
          },
          {
              class: Event,
              existing_records: {action: :destroy, find_by: [:name, :subject_id]},
              event_name: :subject_sleep_habits,
              static_fields: {realtime: Time.zone.now}
          }
      ]
    end



    def init_light_subjects
    end

    def init_fd_subjects
    end


  end
end
