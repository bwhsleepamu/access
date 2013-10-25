class CreateDataValues < ActiveRecord::Migration
  def change
    create_table :data_values do |t|
      t.decimal :num_value
      t.string :text_value
      t.datetime :datetime_value
      t.integer :type_flag
      t.boolean :deleted

      t.timestamps
    end
  end
end
