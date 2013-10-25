class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.text :notes
      t.integer :subject_id
      t.integer :source_id
      t.integer :documentation_id
      t.integer :labtime_hr
      t.integer :labtime_min
      t.integer :labtime_sec
      t.integer :labtime_year
      t.datetime :realtime
      t.integer :group_label
      t.boolean :deleted

      t.timestamps
    end
  end
end
