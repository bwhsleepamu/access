class CreateStudies < ActiveRecord::Migration
  def change
    create_table :studies do |t|
      t.string :official_name
      t.text :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
