pwd = File.expand_path(File.dirname(__FILE__))
require File.join(pwd, "fancygrid", "helper")
require File.join(pwd, "fancygrid", "node")
require File.join(pwd, "fancygrid", "grid")
require File.join(pwd, "version")

module Fancygrid
  pwd = File.expand_path(File.dirname(__FILE__))
  
  mattr_accessor :table_template_path
  @@table_template_path = File.join(pwd, "../app/views/fancygrid/base/_table_frame.html.haml")
  
  mattr_accessor :list_template_path
  @@list_template_path = File.join(pwd, "../app/views/fancygrid/base/_list_frame.html.haml")
  
  mattr_accessor :controls_template_path
  @@controls_template_path = File.join(pwd, "../app/views/fancygrid/base/_controls_frame.html.haml")

  mattr_accessor :default_cells_template_name
  @@default_cells_template_name = "_cells"
  
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
    end

    initializer "fancygrid.initialize" do |app|
    
      plg_prefix = File.join(File.expand_path(File.dirname(__FILE__)), "../app/views/fancygrid")
      app_prefix = Rails.root.join("app/views/fancygrid")
      
      # plugin templates
      plg_table_tpl = File.join(plg_prefix, "base/_table_frame.html.haml")
      plg_list_tpl  = File.join(plg_prefix, "base/_list_frame.html.haml")
      plg_contr_tpl = File.join(plg_prefix, "base/_controls.html.haml")
      plg_cells_tpl = File.join(plg_prefix, "_cells.html.haml")
      
      # custom templates
      app_table_tpl = File.join(app_prefix, "base/_table_frame.html.haml")
      app_list_tpl  = File.join(app_prefix, "base/_list_frame.html.haml")
      app_contr_tpl = File.join(app_prefix, "base/_controls.html.haml")
      app_cells_tpl = File.join(app_prefix, "_cells.html.haml")
      
      # used templates
      # TODO: use the module attributes above instead class variables
      Fancygrid::Grid.table_template   = File.exists?(app_table_tpl) ? app_table_tpl : plg_table_tpl
      Fancygrid::Grid.list_template    = File.exists?(app_list_tpl) ? app_list_tpl : plg_list_tpl
      Fancygrid::Grid.control_template = File.exists?(app_contr_tpl) ? app_contr_tpl : plg_contr_tpl
      Fancygrid::Grid.cells_template = File.exists?(app_cells_tpl) ? app_cells_tpl : plg_cells_tpl

      ActionController::Base.send :include, Fancygrid::Helper
      ActionView::Base.send :include, Fancygrid::Helper
    end
  end
end
   