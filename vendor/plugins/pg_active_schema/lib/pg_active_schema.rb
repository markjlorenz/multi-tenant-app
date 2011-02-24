require 'active_record/connection_adapters/postgresql_adapter'
#This module monkey patches the postgres adapter from rails v3.0.3, since table_exists? checks all existing tables, irreguardless of the
#schema search path.  See:
# https://rails.lighthouseapp.com/projects/8994/tickets/6457-disregard-for-schema-search-path-in-postgresql_adapterrb#ticket-6457-1
module PostgresAdapterPatch
  ActiveRecord::ConnectionAdapters::PostgreSQLAdapter.class_eval do
    alias_method :schema_unfriendly_table_exists?, :table_exists?
    def table_exists?(name)
        name          = name.to_s
        schema, table = name.split('.', 2)
       unless table # A table was provided without a schema
          table  = schema
          schema = nil
        end

        if name =~ /^"/ # Handle quoted table names
          table  = name
          schema = nil
        end

        # `AND schemaname = ANY (current_schemas(false))` added so only tables in the current search path are included
        query(<<-SQL).first[0].to_i > 0
            SELECT COUNT(*)
            FROM pg_tables
            WHERE tablename = '#{table.gsub(/(^"|"$)/,'')}'
            #{schema ? "AND schemaname = '#{schema}'" : ''}
            AND schemaname = ANY (current_schemas(false))
        SQL
      end
  end
end

class PgActiveSchema
  include PostgresAdapterPatch

  class NoSchema < StandardError; end
  class CreateSchemaError < StandardError
    attr_reader :search_path
    def initialize(message = nil, search_path = nil)
      @message = message
      @search_path = search_path
    end
  end
  class DropSchemaError < StandardError
    attr_reader :search_path
    def initialize(message = nil, search_path = nil)
      @message = message
      @search_path = search_path
    end
  end

  
  def self.create_schema name
    begin
      ActiveRecord::Base.connection.execute("CREATE SCHEMA #{name}")
    rescue Exception => e
      drop_schema name if list_schemata.include?(name) #dont' want a 1/2 finished schema hanging around
      raise PgActiveSchema::CreateSchemaError.new(e.message, search_path)
    end
  end

  def self.drop_schema name
    begin
      ActiveRecord::Base.connection.execute("DROP SCHEMA #{name} CASCADE;")
    rescue Exception => e
      raise PgActiveSchema::DropSchemaError.new(e.message, search_path)
    end
  end

  def self.list_schemata
    ActiveRecord::Base.connection.query('SELECT nspname AS "Schema Name" FROM pg_namespace  WHERE nspname !~ \'^pg_.*\';').flatten
  end

  def self.search_path
    ActiveRecord::Base.connection.query('SHOW search_path;')[0].first
  end

  def self.current_schema
    ActiveRecord::Base.connection.query('select current_schema();')[0].first
  end
  
  def self.search_path= name, include_public=false
    path_parts = [name, ("public" if include_public)].compact
    Rails.logger.info "--Setting search path to: " + path_parts.join(',')
    begin
      #this will throw `ActiveRecord::StatementInvalid` if the search path doesn't exist
      #http://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/PostgreSQLAdapter.html#method-i-schema_search_path-3D
      #says not to call this directly, but internally it's doing the same thing I was going to do anyway
      @prior_search_path = search_path
      ActiveRecord::Base.connection.schema_search_path = path_parts.join(',')
    rescue Exception => e
      raise PgActiveSchema::NoSchema.new(e.message)
    end
  end

  def self.restore_search_path
    self.search_path = @prior_search_path
  end

  def self.default_search_path
    self.search_path = '"$user",public'
  end

  #run this to create a new tenant, and initialize with the 'authorative' schema in pg_active_schema/db/schema.rb
  #this plugin schema will have to be managed by hand for now
  #the version listed there should represent our desired latest migration.  The `schema_migrations table` in each postgres schema
  #will tell us whether or not those migrations where actually applied, incase there was some kind of failure.
  def self.create_tenant name
    create_schema name
    self.search_path = name

    #right from db:schema:load rake task
    file = "#{Rails.root}/vendor/plugins/pg_active_schema/db/schema.rb"
    if File.exists?(file)
      load(file)
    else
      abort %{#{file} vendor/plugins/pg_active_schema/db/schema.rb doesn't exist."}
    end
    file = "#{Rails.root}/vendor/plugins/pg_active_schema/db/seeds.rb"
    if File.exists?(file)
      load(file)
    end

    restore_search_path
  end

  #use this to get rid of tenants (i.e. the tenants schema)
  def self.drop_tenant name
    drop_schema name
  end

end
