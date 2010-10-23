$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "../lib"))

require 'active_record'
require 'attribute'
require 'association_builder'
require 'query_builder'

class Ticket < ActiveRecord::Base
  belongs_to :project
end
class Project < ActiveRecord::Base
  has_many :tickets
end