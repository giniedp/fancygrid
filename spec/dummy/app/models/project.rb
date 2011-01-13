class Project < ActiveRecord::Base
  has_many :tickets
end