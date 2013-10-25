class CreateQualityFlags < ActiveRecord::Migration
  def change
    create_table :quality_flags do |t|
      t.string :name
      t.text :description
      t.boolean :deleted

      t.timestamps
    end
  end
end
