class ChangeDatetimeToTimeValue < ActiveRecord::Migration
  def change
    rename_column :data_values, :datetime_value, :time_value
  end
end
