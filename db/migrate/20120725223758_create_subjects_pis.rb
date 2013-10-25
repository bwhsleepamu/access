class CreateSubjectsPis < ActiveRecord::Migration
  def change
    create_table :subjects_pis do |t|
      t.integer :researcher_id
      t.integer :subject_id

      t.timestamps
    end
  end
end
