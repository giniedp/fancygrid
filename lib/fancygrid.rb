pwd = File.expand_path(File.dirname(__FILE__))
require File.join(pwd, "fancygrid", "helper")
require File.join(pwd, "fancygrid", "node")
require File.join(pwd, "fancygrid", "grid")
require File.join(pwd, "fancygrid", "query_generator")
require File.join(pwd, "version")

module Fancygrid
  pwd = File.expand_path(File.dirname(__FILE__))
  
  mattr_accessor :table_template_path
  @@table_template_path = File.join(pwd, "../app/views/fancygrid/base/table_frame.html.haml")
  
  mattr_accessor :list_template_path
  @@list_template_path = File.join(pwd, "../app/views/fancygrid/base/list_frame.html.haml")
  
  mattr_accessor :controls_template_path
  @@controls_template_path = File.join(pwd, "../app/views/fancygrid/base/controls.html.haml")

  mattr_accessor :default_cells_template_name
  @@default_cells_template_name = "cells"
  
  mattr_accessor :use_grid_name_as_cells_template_name
  @@use_grid_name_as_cells_template_name = false
  
  mattr_accessor :search_enabled
  @@search_enabled = false
  
  mattr_accessor :default_grid_type
  @@default_grid_type = :table
  
  mattr_accessor :i18n_tables_prefix
  @@i18n_tables_prefix = "fancygrid.tables"
  
  def self.setup
    yield self
  end
  
  class Railtie < Rails::Railtie

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
   