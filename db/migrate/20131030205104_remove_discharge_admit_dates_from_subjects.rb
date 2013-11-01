class RemoveDischargeAdmitDatesFromSubjects < ActiveRecord::Migration
  def up
    remove_column :subjects, :discharge_date
    remove_column :subjects, :admit_date
  end
  def down
    add_column :subjects, :discharge_date, :date
    add_column :subjects, :admit_date, :date
  end
end
