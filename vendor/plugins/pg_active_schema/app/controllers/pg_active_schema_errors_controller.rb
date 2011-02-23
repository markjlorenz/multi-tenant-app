class PgActiveSchemaErrorsController < ApplicationController
  def no_schema
    @tenant = current_tenant
  end
end