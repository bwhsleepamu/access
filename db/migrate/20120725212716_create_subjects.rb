class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|
      t.string :subject_code
      t.date :admin_date
      t.date :discharge_date
      t.boolean :disempanelled
      t.string :t_drive_location
      t.text :notes
      t.integer :study_id
      t.boolean :deleted

      t.timestamps
    end
  end
end
