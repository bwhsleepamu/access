class RenameSubjectTagsToSubjectGroups < ActiveRecord::Migration
  def up
    remove_foreign_key :subjects_subject_tags, :subjects
    remove_foreign_key :subjects_subject_tags, :subject_tags

    rename_table :subject_tags, :subject_groups
    rename_table :subjects_subject_tags, :subjects_subject_groups
    rename_column :subjects_subject_groups, :subject_tag_id, :subject_group_id

    add_foreign_key :subjects_subject_groups, :subjects, dependent: :delete
    add_foreign_key :subjects_subject_groups, :subject_groups, dependent: :delete
  end

  def down
    remove_foreign_key :subjects_subject_groups, :subjects
    remove_foreign_key :subjects_subject_groups, :subject_groups

    rename_table :subject_groups, :subject_tags
    rename_table :subjects_subject_groups, :subjects_subject_tags
    rename_column :subjects_subject_groups, :subject_group_id, :subject_tag_id

    add_foreign_key :subjects_subject_tags, :subjects, dependent: :delete
    add_foreign_key :subjects_subject_tags, :subject_tags, dependent: :delete
  end
end
