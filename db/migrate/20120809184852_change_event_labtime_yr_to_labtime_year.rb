class ChangeEventLabtimeYrToLabtimeYear < ActiveRecord::Migration
  def change
    rename_column :events, :labtime_hr, :labtime_hour
  end
end
