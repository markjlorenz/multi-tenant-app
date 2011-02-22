#namespace :db do
#  namespace :schema do
#    desc "run db:schema:load into the supplied Postgres schema"
#    task :new_tenant => :environment, :pg_schema do |task, pg_schema|
#      config[env]["schema_search_path"] = schema
#      `rake db:schema:load`
#  
#    end
#
#    task :create_schema, :pg_schema do |task, pg_schema|
#      
#    end
#  end
#end
