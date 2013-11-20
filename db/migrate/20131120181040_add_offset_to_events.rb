class AddOffsetToEvents < ActiveRecord::Migration
  def change
    add_column :events, :realtime_offset_sec, :integer
  end
end
