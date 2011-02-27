require 'active_record/base'
require 'pg_active_schema'

module ActsAsPgActiveSchemaController
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_pg_active_schema_controller(options={})
      raise ArgumentError, "Hash expected, got #{options.class.name}" if not options.is_a?(Hash) and not options.empty?
      send :include, InstanceMethods

      rescue_from PgActiveSchema::NoSchema do |exception|
        respond_to do |format|
          format.html { redirect_to :controller=>:pg_active_schema_errors, :action=>:no_schema, :tenant=>current_tenant }
        end
      end
    end
  end

  module InstanceMethods
    def current_tenant
      if !params[:tenant].blank?
        return params[:tenant]
      elsif !request.subdomain.blank?
        return request.subdomain
      end
    end

    def schema_to_current_tenant
      PgActiveSchema.search_path = current_tenant
    end
    def schema_to_default
      PgActiveSchema.default_search_path
    end
  end

end

ActionController::Base.send :include, ActsAsPgActiveSchemaController