# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pg_active_schema/version"

Gem::Specification.new do |s|
  s.name        = "pg_active_schema"
  s.version     = PgActiveSchema::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["TODO: Write your name"]
  s.email       = ["TODO: Write your email address"]
  s.homepage    = "http://rubygems.org/gems/mini_cms"
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}
  s.require_paths = ["lib"]
  s.rubyforge_project = "pg_active_schema"
  
  #s.add_development_dependency "rspec", ">= 2.5.0"
  s.add_dependency "activerecord", "3.0.4"
  s.add_dependency "win32console", "1.3.0"
  s.add_dependency "rails", ">=3.0.4"
  

  
end