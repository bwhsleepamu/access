class FixTimezones < ActiveRecord::Migration
  def change

    add_column :data_values, :time_offset_sec, :integer

  end
end
