$:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), "../lib"))

require 'active_record'
require 'fancygrid/query_generator'

class Ticket < ActiveRecord::Base
  belongs_to :project
end
class Project < ActiveRecord::Base
  has_many :tickets
end