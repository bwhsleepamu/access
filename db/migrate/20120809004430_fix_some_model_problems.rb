class FixSomeModelProblems < ActiveRecord::Migration
  def change
    remove_column :data_dictionary, :max_length_integer
    add_column :data_dictionary, :max_length, :integer
    change_column :data_values, :type_flag, :string
    change_column :data_dictionary, :multivalue, :boolean, :default => false
    change_column :data, :deleted, :boolean, :null => false, :default => false
    change_column :data_dictionary, :deleted, :boolean, :null => false, :default => false
    change_column :data_types, :deleted, :boolean, :null => false, :default => false
    change_column :data_values, :deleted, :boolean, :null => false, :default => false
    change_column :documentations, :deleted, :boolean, :null => false, :default => false
    change_column :event_dictionary, :deleted, :boolean, :null => false, :default => false
    change_column :event_tags, :deleted, :boolean, :null => false, :default => false
    change_column :events, :deleted, :boolean, :null => false, :default => false
    change_column :irbs, :deleted, :boolean, :null => false, :default => false
    change_column :publications, :deleted, :boolean, :null => false, :default => false
    change_column :quality_flags, :deleted, :boolean, :null => false, :default => false
    change_column :researchers, :deleted, :boolean, :null => false, :default => false
    change_column :source_types, :deleted, :boolean, :null => false, :default => false
    change_column :sources, :deleted, :boolean, :null => false, :default => false
    change_column :studies, :deleted, :boolean, :null => false, :default => false
    change_column :study_nicknames, :deleted, :boolean, :null => false, :default => false
    change_column :subjects, :deleted, :boolean, :null => false, :default => false
  end
end
