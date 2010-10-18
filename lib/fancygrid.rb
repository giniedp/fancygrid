%w(table table_helper result column version).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

# enables rake tasks in the final application
Dir["#{Gem.searcher.find('fancygrid').full_gem_path}/**/tasks/*.rake"].each { |ext| load ext }

module Fancygrid
  class Railtie < Rails::Railtie
    initializer "fancygrid.initialize" do |app|

      # plugin templates
      plg_frame_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "fancygrid", "_frame.html.haml")
      plg_contr_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "fancygrid", "_controls.html.haml")
      plg_cells_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "fancygrid", "_cells.html.haml")
      
      # custom templates
      app_frame_tpl = Rails.root.join("app", "views", "fancygrid", "_frame.html.haml")
      app_contr_tpl = Rails.root.join("app", "views", "fancygrid", "_controls.html.haml")
      app_cells_tpl = Rails.root.join("app", "views", "fancygrid", "_cells.html.haml")
      
      # used templates
      Fancygrid::Table.frame_template = File.exists?(app_frame_tpl) ? app_frame_tpl : plg_frame_tpl
      Fancygrid::Table.control_template = File.exists?(app_contr_tpl) ? app_contr_tpl : plg_contr_tpl
      Fancygrid::Table.cells_template = File.exists?(app_cells_tpl) ? app_cells_tpl : plg_cells_tpl

      ActionController::Base.send :include, Fancygrid::TableHelper
      ActionView::Base.send :include, Fancygrid::TableHelper  
    end
  end
end
   