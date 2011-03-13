# 21-Feb-2011 - Mark J. Lorenz - Dapple Before Dawn ltd.
#
# This rake task will run the migrations in vendor/plugins/pg_active_schema/db/migrate/ once for each existing schema
# This is how you would upgrade existing tenants.  To create new tenants use PgActiveSchem::create_tenant, which will run the plugin's 
# version of `db/schema.rb`.
#

require 'active_record'
require 'pg'

# add a delete_task method to the TaskManager and delete db:migrate
Rake::TaskManager.class_eval do
  def delete_task(task_name)
    @tasks.delete(task_name.to_s)
  end
  %w{db:migrate db:migrate:up db:migrate:down db:rollback}.each {|t| Rake.application.delete_task(t) }
end

desc 'Loading schema.rb vendor/plugins/pg_active_schema\db into a new tenant 
namespace :schema do
task :load_schema, :environment do   
	  origin      = File.join("#{Rails.root}/vendor/plugins/pg_active_schema/db/migrate")
	  config = YAML::load(File.open("#{Rails.root}/config/database.yml") )
      ActiveRecord::Base.establish_connection(config[env])
      Rake::Task["db:schema:load"].execute
 end
end
