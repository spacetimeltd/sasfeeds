class CreateStuffs < ActiveRecord::Migration
  def change
    create_table :stuffs do |t|
      t.string :name
      t.text :data

      t.timestamps
    end
  end
end
