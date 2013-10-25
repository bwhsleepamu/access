class CreateDataQualityFlags < ActiveRecord::Migration
  def change
    create_table :data_quality_flags do |t|
      t.integer :datum_id
      t.integer :quality_flag_id

      t.timestamps
    end
  end
end
