class AddChangeLogRefactorSourceDocumentation < ActiveRecord::Migration
  def up
    execute "create sequence object_id_seq minvalue 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER NOCYCLE"
    create_table :change_logs do |t|
      t.integer :object_id
      t.integer :source_id
      t.integer :documentation_id
      t.integer :user_id
      t.string :action_type
      t.datetime :timestamp
      t.timestamps
    end
  end

  def down
    execute "drop sequence object_id_seq"
    drop_table :change_logs
  end

end
