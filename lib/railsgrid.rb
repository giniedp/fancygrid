%w(table table_helper result column version).each do |file|
  require File.join(File.dirname(__FILE__), file)
end

module Railsgrid
  class Railtie < Rails::Railtie
    initializer "railsgrid.initialize" do |app|

      # plugin templates
      plg_frame_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "railsgrid", "_frame.html.haml")
      plg_contr_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "railsgrid", "_controls.html.haml")
      plg_cells_tpl = File.join(File.expand_path(File.dirname(__FILE__)), "..", "app", "views", "railsgrid", "_cells.html.haml")
      
      # custom templates
      app_frame_tpl = Rails.root.join("app", "views", "railsgrid", "_frame.html.haml")
      app_contr_tpl = Rails.root.join("app", "views", "railsgrid", "_controls.html.haml")
      app_cells_tpl = Rails.root.join("app", "views", "railsgrid", "_cells.html.haml")
      
      # used templates
      Railsgrid::Table.frame_template = File.exists?(app_frame_tpl) ? app_frame_tpl : plg_frame_tpl
      Railsgrid::Table.control_template = File.exists?(app_contr_tpl) ? app_contr_tpl : plg_contr_tpl
      Railsgrid::Table.cells_template = File.exists?(app_cells_tpl) ? app_cells_tpl : plg_cells_tpl

      ActionController::Base.send :include, Railsgrid::TableHelper
      ActionView::Base.send :include, Railsgrid::TableHelper  
    end
  end
end
   