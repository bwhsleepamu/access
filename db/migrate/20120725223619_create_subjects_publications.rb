class CreateSubjectsPublications < ActiveRecord::Migration
  def change
    create_table :subjects_publications do |t|
      t.integer :subject_id
      t.integer :publication_id

      t.timestamps
    end
  end
end
