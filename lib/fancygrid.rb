require "fancygrid"
require "fancygrid/node"
require "fancygrid/grid"
require "fancygrid/column"
require "fancygrid/view_state"
require "fancygrid/object_wrapper"

require "fancygrid/orm/sql_generator"
require "fancygrid/orm/active_record"

require "fancygrid/controller/helper"
require "fancygrid/view/helper"

module Fancygrid
  
  mattr_accessor :base_template
  @@base_template = "fancygrid/fancygrid"
    
  mattr_accessor :table_template
  @@table_template = "fancygrid/table"
  
  mattr_accessor :controls_template
  @@controls_template = "fancygrid/controls"

  mattr_accessor :sort_template
  @@sort_template = "fancygrid/sort"
    
  mattr_accessor :search_template
  @@search_template = "fancygrid/search"

  mattr_accessor :i18n_scope
  @@i18n_scope = "fancygrid"

  mattr_accessor :components
  @@components = [:top_bar, :bottom_bar, :search_bar, :table]

  mattr_accessor :orm
  @@orm = "fancygrid/orm/active_record"
      
  mattr_accessor :hide_search
  @@hide_search = true
  
  mattr_accessor :search_operators
  @@search_operators = Fancygrid::Orm::SqlGenerator::OPERATOR_NAMES
  
  mattr_accessor :search_operator
  @@search_operator = :like
    
  mattr_accessor :per_page_values
  @@per_page_values = [5, 10, 15, 20, 25, 30, 40, 50, 100]
  
  mattr_accessor :per_page_value
  @@per_page_value = 20

  mattr_accessor :ajax_type
  @@ajax_type = :get

  mattr_accessor :persist_state
  @@persist_state = false
  
  def self.setup
    yield self
  end
  
  def self.default_options
    {
      :base_template => self.base_template,
      :table_template => self.table_template,
      :controls_template => self.controls_template,
      :sort_template => self.sort_template,
      :search_template => self.search_template,
      :i18n_scope => self.i18n_scope,
      :components => self.components,
      :orm => self.orm,
      :hide_search => self.hide_search,
      :search_operators => self.search_operators,
      :search_operator => self.search_operator,
      :per_page_values => self.per_page_values,
      :per_page_value => self.per_page_value,
      :ajax_type => self.ajax_type,
      :persist_state => self.persist_state
    }
  end
  
  class Engine < Rails::Engine#:nodoc:
    initializer "fancygrid.initialize" do |app|
      ActionController::Base.send :include, Fancygrid::Controller::Helper
      ActionView::Base.send :include, Fancygrid::View::Helper
    end
  end
end
   