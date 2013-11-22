=begin
  Sources will be the original files
  Documentation - PSQ Master File??
=end


module ETL
  class NewFormsLoader


  end
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
      { target: :irb, field: :number, multiple: true },
      { target: :researcher, field: :full_name, researcher_type: :pi, multiple: true },
      { target: :researcher, field: :full_name, researcher_type: :pl, role: :original },
      { target: :researcher, field: :full_name, researcher_type: :pl, role: :current },
      { target: :subject, field: :admit_date },
      { target: :subject, field: :discharge_date },
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
          existing_records: {action: :update, find_by: [:number]}
      }
  ]
end
