class CreateIrbs < ActiveRecord::Migration
  def change
    create_table :irbs do |t|
      t.string :title
      t.string :number
      t.boolean :deleted

      t.timestamps
    end
  end
end
