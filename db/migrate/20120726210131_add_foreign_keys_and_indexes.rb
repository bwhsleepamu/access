class AddForeignKeysAndIndexes < ActiveRecord::Migration
  def change
    add_foreign_key :data_data_values, :data
    add_foreign_key :data_data_values, :data_values
    add_index :data_data_values, :data_value_id
    add_index :data_data_values, :datum_id

    add_foreign_key :data_quality_flags, :data
    add_foreign_key :data_quality_flags, :quality_flags
    add_index :data_quality_flags, :datum_id
    add_index :data_quality_flags, :quality_flag_id

    add_foreign_key :event_quality_flags, :events
    add_foreign_key :event_quality_flags, :quality_flags
    add_index :event_quality_flags, :event_id
    add_index :event_quality_flags, :quality_flag_id

    add_foreign_key :events, :subjects
    add_foreign_key :events, :sources
    add_foreign_key :events, :documentations
    add_index :events, :subject_id
    add_index :events, :source_id
    add_index :events, :documentation_id

    add_foreign_key :sources, :users
    add_foreign_key :sources, :source_types
    add_index :sources, :user_id
    add_index :sources, :source_type_id

    add_foreign_key :study_nicknames, :studies
    add_index :study_nicknames, :study_id

    add_foreign_key :subjects, :studies
    add_index :subjects, :study_id

    add_foreign_key :documentations, :users
    add_index :documentations, :user_id

    add_foreign_key :data, :sources
    add_foreign_key :data, :documentations
    add_foreign_key :data, :events
    add_index :data, :source_id
    add_index :data, :documentation_id
    add_index :data, :event_id

    add_foreign_key :subjects_irbs, :subjects
    add_foreign_key :subjects_irbs, :irbs
    add_index :subjects_irbs, :subject_id
    add_index :subjects_irbs, :irb_id

    add_foreign_key :subjects_publications, :subjects
    add_foreign_key :subjects_publications, :publications
    add_index :subjects_publications, :subject_id
    add_index :subjects_publications, :publication_id

    add_foreign_key :subjects_project_leaders, :subjects
    add_foreign_key :subjects_project_leaders, :researchers
    add_index :subjects_project_leaders, :subject_id
    add_index :subjects_project_leaders, :researcher_id

    add_foreign_key :subjects_pis, :subjects
    add_foreign_key :subjects_pis, :researchers
    add_index :subjects_pis, :subject_id
    add_index :subjects_pis, :researcher_id
  end
end
