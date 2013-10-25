class CreateSubjectsIrbs < ActiveRecord::Migration
  def change
    create_table :subjects_irbs do |t|
      t.integer :subject_id
      t.integer :irb_id

      t.timestamps
    end
  end
end
