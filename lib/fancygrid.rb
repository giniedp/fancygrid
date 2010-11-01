# require plugin code files
%w(helper node grid).each do |file|
  require File.join(File.dirname(__FILE__), "fancygrid", file)
end
require File.join(File.dirname(__FILE__), "version")

# enables rake tasks in the final application
Dir["#{Gem.searcher.find('fancygrid').full_gem_path}/**/tasks/*.rake"].each { |ext| load ext }

module Fancygrid
  class Railtie < Rails::Railtie
    initializer "fancygrid.initialize" do |app|

      plg_prefix = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "fancygrid")
      app_prefix = Rails.root.join("app", "views", "fancygrid")
      
      # plugin templates
      plg_table_tpl = File.join(plg_prefix, "_table_frame.html.haml")
      plg_list_tpl  = File.join(plg_prefix, "_list_frame.html.haml")
      plg_contr_tpl = File.join(plg_prefix, "_controls.html.haml")
      plg_cells_tpl = File.join(plg_prefix, "_cells.html.haml")
      
      # custom templates
      app_table_tpl = File.join(app_prefix, "_table_frame.html.haml")
      app_list_tpl  = File.join(plg_prefix, "_list_frame.html.haml")
      app_contr_tpl = File.join(app_prefix, "_controls.html.haml")
      app_cells_tpl = File.join(app_prefix, "_cells.html.haml")
      
      # used templates
      Fancygrid::Grid.table_template   = File.exists?(app_table_tpl) ? app_table_tpl : plg_table_tpl
      Fancygrid::Grid.list_template    = File.exists?(app_list_tpl) ? app_list_tpl : plg_list_tpl
      Fancygrid::Grid.control_template = File.exists?(app_contr_tpl) ? app_contr_tpl : plg_contr_tpl
      Fancygrid::Grid.cells_template   = File.exists?(app_cells_tpl) ? app_cells_tpl : plg_cells_tpl

      ActionController::Base.send :include, Fancygrid::Helper
      ActionView::Base.send :include, Fancygrid::Helper
    end
  end
end
   