class Tenant < ActiveRecord::Base
  validates :subdomain, :presence=>true,
                        :format=>{:with => /^[A-Za-z0-9-]+$/, :message => "The subdomain can only contant number, letters and '-'s"},
                        :uniqueness=>{:case_sensitive=>false}
end
