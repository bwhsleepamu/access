class SplitUpAdmitDischargeDataFields < ActiveRecord::Migration
  def change
    add_column :subjects, :admit_day, :integer
    add_column :subjects, :admit_month, :integer
    add_column :subjects, :admit_year, :integer
    add_column :subjects, :discharge_day, :integer
    add_column :subjects, :discharge_month, :integer
    add_column :subjects, :discharge_year, :integer
  end
end
