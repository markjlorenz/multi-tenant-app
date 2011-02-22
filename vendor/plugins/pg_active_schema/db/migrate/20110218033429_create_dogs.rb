class CreateDogs < ActiveRecord::Migration
  def self.up
    #execute "CREATE SCHEMA mark;"
    #execute "SET search_path TO mark;"
    create_table :dogs do |t|
      t.string :name
      t.string :size

      t.timestamps
    end

   # execute "SET search_path TO public;"
  end

  def self.down
    drop_table :dogs
  end
end
