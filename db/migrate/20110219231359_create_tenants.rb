class CreateTenants < ActiveRecord::Migration
  def self.up
    create_table :tenants do |t|
      t.string :subdomain
      t.string :user_name

      t.timestamps
    end
  end

  def self.down
    drop_table :tenants
  end
end
