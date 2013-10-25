class AddMissingIndexes < ActiveRecord::Migration
  def change
    ## WARNING: BITMAP FUNCTIONALITY MUST BE ADDED TO ORACLE ENHANCED

    add_index :data, :deleted, :bitmap => true
    add_index :subjects, :deleted, :bitmap => true
    add_index :study_nicknames, :deleted, :bitmap => true
    add_index :studies, :deleted, :bitmap => true
    add_index :sources, :deleted, :bitmap => true
    add_index :source_types, :deleted, :bitmap => true
    add_index :researchers, :deleted, :bitmap => true
    add_index :data_types, :deleted, :bitmap => true
    add_index :publications, :deleted, :bitmap => true
    add_index :irbs, :deleted, :bitmap => true
    add_index :events, :deleted, :bitmap => true
    add_index :event_dictionary, :deleted, :bitmap => true
    add_index :documentations, :deleted, :bitmap => true
    add_index :event_tags, :deleted, :bitmap => true
    add_index :data_values, :type_flag, :bitmap => true
    add_index :data_values, :deleted, :bitmap => true
    add_index :subjects_project_leaders, :role, :bitmap => true


    add_index :data, :title

    add_index :change_logs, :model_id
    add_index :change_logs, :source_id
    add_index :change_logs, :documentation_id
    add_index :change_logs, :user_id
    add_index :change_logs, :action_type

    add_index :data_types, :name

    add_index :documentations, :title
    add_index :documentations, :author
    add_index :documentations, [:title, :author]

    add_index :event_dictionary_data_fields, [:event_dictionary_id, :data_dictionary_id]

    add_index :event_dictionary_event_tags, [:event_dictionary_id, :event_tag_id]

    add_index :event_quality_flags, [:event_id, :quality_flag_id]

    add_index :events, :name
    add_index :events, :group_label
    add_index :events, :realtime
    add_index :events, [:labtime_hour, :labtime_min, :labtime_sec, :labtime_year]

    add_index :irbs, :number

    add_index :publications, :pubmed_id
    add_index :publications, :title

    add_index :quality_flags, :name

    add_index :researchers, :email
    add_index :researchers, :last_name
    add_index :researchers, [:first_name, :last_name]

    add_index :source_types, :name

    add_index :sources, :location

    add_index :studies, :official_name

    add_index :study_nicknames, :nickname

    add_index :subjects, :subject_code

    add_index :subjects_project_leaders, [:researcher_id, :subject_id]

    add_index :subjects_irbs, [:subject_id, :irb_id]

    add_index :subjects_pis, [:researcher_id, :subject_id]

    add_index :subjects_publications, [:subject_id, :publication_id]
  end

end
