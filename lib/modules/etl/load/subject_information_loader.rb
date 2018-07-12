module ETL
  class SubjectInformationLoader

    def initialize(source_path, subject_type, source, documentation)
      begin               
        @data_info = { path: source_path, skip_lines: 1, header: true }
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

    def init_light_subjects
      @column_map += [
        { target: :datum, field: :polychromatic_light_source, event_name: :polychromatic_light_intervention },
        { target: :datum, field: :polychromatic_light_level_target, event_name: :polychromatic_light_intervention },
        { target: :datum, field: :polychromatic_light_level_measured, event_name: :polychromatic_light_intervention },
        { target: :datum, field: :monochromatic_light_wavelength, event_name: :monochromatic_light_intervention },
        { target: :datum, field: :monochromatic_light_irradiance_target, event_name: :monochromatic_light_intervention },
        { target: :datum, field: :monochromatic_light_photon_flux_target, event_name: :monochromatic_light_intervention },
        { target: :datum, field: :monochromatic_light_irradiance_measured, event_name: :monochromatic_light_intervention },
        { target: :datum, field: :monochromatic_light_photon_flux_measured, event_name: :monochromatic_light_intervention }
      ]


      @object_map += [        
        {
          class: Event,
          existing_records: {action: :destroy, find_by: [:name, :subject_id]},
          event_name: :polychromatic_light_intervention,
          static_fields: {realtime: Time.zone.now}
        },
        {
          class: Event,
          existing_records: {action: :destroy, find_by: [:name, :subject_id]},
          event_name: :monochromatic_light_intervention,
          static_fields: {realtime: Time.zone.now}
        }
      ]
    end

    def init_fd_subjects
      @column_map += [
        { target: :datum, field: :age_group, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :t_cycle, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :sleep_period_duration, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :wake_period_duration, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :analysis_start_time, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :analysis_end_time, event_name: :forced_desynchrony_subject_information },
        { target: :datum, field: :intervention, event_name: :forced_desynchrony_subject_information }
      ]

      @object_map += [        
        {
          class: Event,
          existing_records: {action: :destroy, find_by: [:name, :subject_id]},
          event_name: :forced_desynchrony_subject_information,
          static_fields: {realtime: Time.zone.now}
        }
      ]
    end

    def init_column_map
      @column_map = [
        { target: :subject, field: :subject_code },
        { target: :subject, field: :t_drive_location},
        { target: :study, field: :official_name },
        { target: :study, field: :nicknames },
        { target: :irb, field: :title, multiple: true },
        { target: :irb, field: :irb_number, multiple: true },
        { target: :researcher, field: :full_name, researcher_type: :pi, multiple: true },
        { target: :researcher, field: :full_name, researcher_type: :pl, role: :original },
        { target: :researcher, field: :full_name, researcher_type: :pl, role: :current },
        { target: :subject, field: :study_year },
        { target: :subject, field: :admit_month },
        # { target: :subject, field: :admit_day },
        # { target: :subject, field: :discharge_year },
        { target: :subject, field: :discharge_month },
        # { target: :subject, field: :discharge_day },
        { target: :subject, field: :disempanelled },
        { target: :subject, field: :notes }
      ]
    end

    def init_object_map
      @object_map = [
        {
          class: Subject,
          existing_records: {action: :update, find_by: [:subject_code]}
        },
        {
          class: Study,
          existing_records: {action: :update, find_by: [:official_name]}
        },
        {
          class: Researcher,
          existing_records: {action: :update, find_by: [:full_name]},
          researcher_type: :pi
        },
        {
          class: Researcher,
          existing_records: {action: :update, find_by: [:full_name]},
          researcher_type: :pl,
          role: :original
        },
        {
          class: Researcher,
          existing_records: {action: :update, find_by: [:full_name]},
          researcher_type: :pl,
          role: :current
        },
        {
          class: Irb,
          existing_records: {action: :update, find_by: [:irb_number]}
        }
      ]    
    end

  end
end

