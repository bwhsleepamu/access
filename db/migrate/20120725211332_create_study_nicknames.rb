class CreateStudyNicknames < ActiveRecord::Migration
  def change
    create_table :study_nicknames do |t|
      t.integer :study_id
      t.string :nickname
      t.boolean :deleted

      t.timestamps
    end
  end
end
