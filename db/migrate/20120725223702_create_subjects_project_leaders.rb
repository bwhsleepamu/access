class CreateSubjectsProjectLeaders < ActiveRecord::Migration
  def change
    create_table :subjects_project_leaders do |t|
      t.integer :researcher_id
      t.integer :subject_id
      t.string :role
      t.text :notes

      t.timestamps
    end
  end
end
