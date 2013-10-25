class CreatePublications < ActiveRecord::Migration
  def change
    create_table :publications do |t|
      t.integer :pubmed_id
      t.integer :endnote_id
      t.string :title
      t.string :authors
      t.string :journal
      t.string :year
      t.text :notes
      t.boolean :deleted

      t.timestamps
    end
  end
end
