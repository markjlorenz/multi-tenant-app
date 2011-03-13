#require 'tasks/schema_migrator'
#include SchemaMigrator

# add a delete_task method to the TaskManager and delete db:migrate
Rake::TaskManager.class_eval do
  def delete_task(task_name)
    @tasks.delete(task_name.to_s)
  end
  %w{db:migrate db:migrate:up db:migrate:down db:rollback}.each {|t| Rake.application.delete_task(t) }
end

#define a new db:migrate and runs migration files under db/migrate 
#Specify SIM=true (SIM==SchemaIteratingMigration), for schema_iterating migration 
##without the option above, it will just do migration files under db/migrate -- the shared schema
namespace :db do

  desc "Migrate the database through scripts in db/migrate"
    task :migrate => :environment do  
       migrator  
  end  
  
  desc "Loading schema.rb vendor/plugins/pg_active_schema/db into a new tenant "
  task :load_schema, :environment do   
	  schema_loader  
 end
  
  desc "Rolls, the schema back to the previous version. Specify the number of steps with STEP=n. Specify SIM=true if for schema_iterating_migration."
  task :rollback => :environment do
     rollbacker 
  end  
  
  namespace :migrate do
    desc "Runs the 'up' for a given migration VERSION. Add SIM=true if for schema_iterating_migration."
    task :up => :environment do
      upward 
    end

    desc "Runs the 'down' for a given migration VERSION. Add SIM=true if for schema_iterating_migration."
    task :down => :environment do
      downward   
    end    
  end  
end
 
 desc "say gud morning"
 task :hello => :environment do
   hello
 end

# seperation before the method called in each tasks. This methods were required to make testing easy

 def migrator
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
    do_schemas_iterating_migrations {|path|  ActiveRecord::Migrator.run(:up, path, version) } 
  end
  
  def schema_loader
     do_schemas_iterating_migrations 
  end
  
   def rollbacker
     step = ENV['STEP'] ? ENV['STEP'].to_i : 1
     do_schemas_iterating_migrations {|path|  ActiveRecord::Migrator.rollback(path, step) }   
   end
   
   def upward
     version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      do_schemas_iterating_migrations {|path|  ActiveRecord::Migrator.run(:up, path, version) }   
   end
   
   def downward
     version = ENV["VERSION"] ? ENV["VERSION"].to_i : nil
      raise "VERSION is required" unless version
      do_schemas_iterating_migrations {|path|  ActiveRecord::Migrator.run(:down, path, version) } 
   end
   
   def hello
    puts "say gud morning"
   end
   
   #just some seperation before the methods below which are not called directly in each task
   
   def add_schema_to_search_path(sc)
  conn ActiveRecord::Base.connection
  saved_path = conn.execute("SHOW search_path")[0][0] # Save current path
  schema_set = schema.downcase == saved_path.split(',').first.strip.downcase # If it's set we don't do much here...
  conn.execute(%Q<SET search_path TO "#{schema}", #{conn.schema_search_path}>) if !schema_set
  end
  
  def do_schemas_iterating_migrations
  #if ENV['SIM']
  if task :load_schema ||  ENV['SIM']
    config ||= YAML.load(File.open("#{Rails.root}/config/database.yml"))
    orig_path = ActiveRecord::Base.connection.schema_search_path
	#sites_schemas = Object.const_get(sim_plugin_config[:class_name]).send(sim_plugin_config[:field_name]) rescue []
    #sites_schemas.each do|schema_name| 
	schemas_file = "#{Rails.root}/vendor/plugins/pg_active_schema/db/schema.rb"
    if File.exists?(file)
	 run "rake db:schema:load"
      puts "== Migrating schema: #{schema_name} =="
      add_schema_to_search_path(schema_name)
      yield('/vendor/plugins/pg_active_schema/db/migrate') 
      # Reset search path to the origin
      conn.execute("SET search_path TO #{conn.schema_search_path}")
    end
  else
    yield('db/migrate')
  end
 end

 