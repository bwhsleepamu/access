class AddLabtimeTimezoneToEvent < ActiveRecord::Migration
  def change
    add_column :events, :labtime_timezone, :string
  end
end
