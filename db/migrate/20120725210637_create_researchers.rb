class CreateResearchers < ActiveRecord::Migration
  def change
    create_table :researchers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :notes
      t.boolean :deleted

      t.timestamps
    end
  end
end
