class FixSubjectGroupDeletedColumn < ActiveRecord::Migration
  def change
    change_column :subject_groups, :deleted, :boolean, :null => false, :default => false
  end
end

