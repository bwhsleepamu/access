class AddSubjectToSource < ActiveRecord::Migration
  def change
    add_column :sources, :subject_id, :integer
    add_foreign_key :sources, :subjects
  end
end
