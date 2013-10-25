class ChangeToAdmitDate < ActiveRecord::Migration
  def change
     rename_column :subjects, :admin_date, :admit_date
  end
end
