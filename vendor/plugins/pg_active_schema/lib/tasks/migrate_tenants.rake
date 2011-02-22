# 21-Feb-2011 - Mark J. Lorenz - Dapple Before Dawn ltd.
#
# This rake task will run the migrations in vendor/plugins/pg_active_schema/db/migrate/ once for each existing schema
# This is how you would upgrade existing tenants.  To create new tenants use PgActiveSchem::create_tenant, which will run the plugin's 
# version of `db/schema.rb`.
#

require 'active_record'
require 'pg'


