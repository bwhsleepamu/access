class FixIrbNumberColumnName < ActiveRecord::Migration
  def change
    rename_column :irbs, :number, :irb_number
  end
end
