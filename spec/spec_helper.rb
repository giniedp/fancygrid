# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"
require "rspec/rails"

ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = true
ActionMailer::Base.default_url_options[:host] = "test.com"

Rails.backtrace_cleaner.remove_silencers!

# Configure capybara for integration testing
require "capybara/rails"
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css

# Run any available migration
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  # Remove this line if you don't want RSpec's should and should_not
  # methods or matchers
  require 'rspec/expectations'
  config.include RSpec::Matchers

  # == Mock Framework
  config.mock_with :rspec
end


#$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "../lib"))
#
#require 'active_record'
#require 'fancygrid/query_generator'
#
#class Ticket < ActiveRecord::Base
#  belongs_to :project
#end
#class Project < ActiveRecord::Base
#  has_many :tickets
#end
#
#class User < ActiveRecord::Base
#  has_and_belongs_to_many :roles
#end
#class Role < ActiveRecord::Base
#  has_and_belongs_to_many :users
#end