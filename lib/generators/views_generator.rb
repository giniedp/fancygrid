module Fancygrid
  module Generators#:nodoc:
    
    class ViewsGenerator < Rails::Generators::Base#:nodoc:

      def copy_views
        %w(controls list_frame table_frame).each do |name|
          plugin_path = File.join(File.dirname(__FILE__), "../../app/views/fancygrid/base/#{name}.html.haml")
          rails_path = Rails.root.join("app/views/fancygrid/base/#{name}.html.haml")
          copy_file(plugin_path, rails_path)
        end
      end

      def print_info
        puts "====================================================================="
        puts ""
        puts "  Add the following lines to the fancygrid initializer"
        puts "  ----------------------------------------------------"
        puts ""
        puts '  config.table_template_path    = Rails.root.join("app/views/fancygrid/base/table_frame.html.haml")'
        puts '  config.list_template_path     = Rails.root.join("app/views/fancygrid/base/list_frame.html.haml")'
        puts '  config.controls_template_path = Rails.root.join("app/views/fancygrid/base/controls.html.haml")'
        puts ""
        puts "====================================================================="
      end
    end
  end
  
end