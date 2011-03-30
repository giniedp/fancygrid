module Fancygrid
  module Generators#:nodoc:
    
    class InstallGenerator < Rails::Generators::Base#:nodoc:

      def copy_initializer
        plugin_path = File.join(File.dirname(__FILE__), "../../config/initializers/fancygrid.rb")
        rails_path = Rails.root.join('config/initializers/fancygrid.rb')
        copy_file(plugin_path, rails_path)
      end
    
      def copy_default_cells_view
        plugin_path = File.join(File.dirname(__FILE__), "../../app/views/fancygrid/_cells.html.haml")
        rails_path = Rails.root.join("app/views/fancygrid/_cells.html.haml")
        copy_file(plugin_path, rails_path)
      end
      
      def copy_javascript_source
        js_source = File.join(File.dirname(__FILE__), '../../public/javascripts/fancygrid.js')
        js_target = Rails.root.join('public/javascripts/fancygrid.js')
        copy_file(js_source, js_target)
      end
      
      def copy_css
        %w(css scss).each do |ext|
          js_source = File.join(File.dirname(__FILE__), "../../public/stylesheets/fancygrid.#{ext}")
          js_target = Rails.root.join("public/stylesheets/fancygrid.#{ext}")
          copy_file(js_source, js_target)
        end
      end
      
      def copy_images
        %w(add.png clear.png ddn.png dn.png dots.png loading.gif magnifier.png next.png order.png prev.png reload.png remove.png spacer.gif submit.png th_bg.png up.png uup.png).each do |filename|
          plugin_path = File.join(File.dirname(__FILE__), "../../public/images/fancygrid", filename)
          rails_path = Rails.root.join('public/images/fancygrid', filename)
          copy_file(plugin_path, rails_path)
        end
      end

      def copy_locale
        %w(de en).each do |locale|
          plugin_path = File.join(File.dirname(__FILE__), "../../config/locales/fancygrid.#{locale}.yml")
          rails_path = Rails.root.join("config/locales/fancygrid.#{locale}.yml")
          copy_file(plugin_path, rails_path)
        end
      end

      def print_info
        puts "====================================================================="
        puts ""
        puts "  Almost done. Next steps you have to do yourself"
        puts "  -----------------------------------------------"
        puts "  1 include the javascript file in your layout : \"= javascript_include_tag 'fancygrid'\""
        puts "  2 include the stylesheet file in your layout : \"= stylesheet_link_tag 'fancygrid'\""
        puts ""
        puts "====================================================================="
      end
    end
  end
  
end