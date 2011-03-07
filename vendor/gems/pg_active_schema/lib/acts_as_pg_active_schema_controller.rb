require 'active_record/base'
require 'pg_active_schema'

module ActsAsPgActiveSchemaController
    extend ActiveSupport::Concern
	
	module ClassMethods
    def acts_as_pg_active_schema_controller(options={})
      raise ArgumentError, "Hash expected, got #{options.class.name}" if not options.is_a?(Hash) and not options.empty?
      include InstanceMethods   #will double check if we still need this here

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
  end

end

class ActionController::Base
 include ActsAsPgActiveSchemaController
end