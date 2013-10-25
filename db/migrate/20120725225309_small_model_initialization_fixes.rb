class SmallModelInitializationFixes < ActiveRecord::Migration
  def change
    add_column :data, :event_id, :integer
  end
end
