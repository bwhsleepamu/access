class CreateEventQualityFlags < ActiveRecord::Migration
  def change
    create_table :event_quality_flags do |t|
      t.integer :event_id
      t.integer :quality_flag_id

      t.timestamps
    end
  end
end
