require "fancygrid"
require "version"
require "fancygrid/helper"
require "fancygrid/node"
require "fancygrid/grid"
require "fancygrid/query_generator"
require "fancygrid/view"

module Fancygrid

  mattr_accessor :table_template
  @@table_template = "fancygrid/base/table_frame"
  
  mattr_accessor :list_template
  @@list_template = "fancygrid/base/list_frame"
  
  mattr_accessor :controls_template
  @@controls_template = "fancygrid/base/controls"

  mattr_accessor :sort_template
  @@sort_template = "fancygrid/base/sort"
    
  mattr_accessor :search_template
  @@search_template = "fancygrid/base/search"

  mattr_accessor :cells_template_directory
  @@cells_template_directory = "fancygrid/"
  
  mattr_accessor :cells_template
  @@cells_template = "_cells"

  mattr_accessor :i18n_scope
  @@i18n_scope = "fancygrid"
  
  mattr_accessor :use_grid_name_as_cells_template
  @@use_grid_name_as_cells_template = false
  
  mattr_accessor :search_visible
  @@search_visible = false
  
  mattr_accessor :default_search_type
  @@default_search_type = :simple
  
  mattr_accessor :default_grid_type
  @@default_grid_type = :table
  
  mattr_accessor :default_per_page_options
  @@default_per_page_options = [5, 10, 15, 20, 25, 30, 40, 50]
  
  mattr_accessor :default_per_page_selection
  @@default_per_page_selection = 20
  
  mattr_accessor :search_operators
  @@search_operators = Fancygrid::QueryGenerator::OPERATOR_NAMES
  
  def self.setup
    yield self
  end
  
  class Engine < Rails::Engine#:nodoc:

    generators do
      require File.join(File.dirname(__FILE__), "generators", "install_generator")
      require File.join(File.dirname(__FILE__), "generators", "views_generator")
      require File.join(File.dirname(__FILE__), "generators", "scss_generator")
    end

    initializer "fancygrid.initialize" do |app|
      ActionController::Base.send :include, Fancygrid::Helper
      ActionView::Base.send :include, Fancygrid::Helper
    end
  end
end
   