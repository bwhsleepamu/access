class ChangeObjectIdToModelId < ActiveRecord::Migration
  def change
    rename_column :change_logs, :object_id, :model_id
  end
end
