$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "activerecord_sqlserver_crm/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "activerecord_sqlserver_crm"
  s.version     = ActiverecordSqlserverCrm::VERSION
  s.authors     = ["Rolf Lawrenz"]
  s.email       = ["rolf.lawrenz@gmail.com"]
  s.homepage    = "https://github.com/RolfLawrenz/activerecord_sqlserver_crm"
  s.summary     = "A rails engine that uses ActiveRecord SQL Server to read from CRM SQL Server, and OData to write to CRM."
  s.description = "A rails engine that uses ActiveRecord SQL Server to read from CRM SQL Server, and OData to write to CRM."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"
  s.add_dependency "activerecord-sqlserver-adapter", '>= 4.2.13'
  s.add_dependency "tiny_tds", '~> 0.7.0'
  s.add_dependency 'typhoeus', '~> 0.8.0'

  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'byebug'
end
