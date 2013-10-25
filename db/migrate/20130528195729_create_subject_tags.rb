class CreateSubjectTags < ActiveRecord::Migration
  def change
    create_table :subject_tags do |t|
      t.string :name
      t.text :description
      t.boolean :deleted

      t.timestamps
    end

    create_table :subjects_subject_tags do |t|
      t.integer :subject_id
      t.integer :subject_tag_id
    end

    add_foreign_key :subjects_subject_tags, :subjects, dependent: :delete
    add_foreign_key :subjects_subject_tags, :subject_tags, dependent: :delete

    add_index :subjects_subject_tags, :subject_id
    add_index :subjects_subject_tags, :subject_tag_id
    add_index :subject_tags, :name
  end
end
