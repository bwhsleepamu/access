
class UpdateSubjectTableForHippaCompliance < ActiveRecord::Migration
  def change
    rename_column :subjects, :admit_year, :study_year
    remove_column :subjects, :discharge_year, :integer # specifying data type for possible rolling back
    remove_column :subjects, :discharge_day, :integer
    remove_column :subjects, :admit_day, :integer
  end
end
