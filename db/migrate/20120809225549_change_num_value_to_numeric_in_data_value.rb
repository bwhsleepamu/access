class ChangeNumValueToNumericInDataValue < ActiveRecord::Migration
  def up
    change_column :data_values, :num_value, :float
  end

  def down
    change_column :data_values, :num_value, :integer
  end
end
