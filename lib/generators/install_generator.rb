module Fancygrid
  module Generators
    
    class InstallGenerator < Rails::Generators::Base

      def copy_initializer

      end
    
      def copy_javascript_source
        js_source = File.join(File.dirname(__FILE__), '../../public/javascripts/fancygrid.js')
        js_target = Rails.root.join('public/javascripts/fancygrid.js')
        copy_file(js_source, js_target)
      end
      
      def copy_images
        %w(add.png clear.png ddn.png dn.png first.png loading.gif magnifier.png next.png prev.png reload.png th_bg.png up.png uup.png spacer.gif).each do |filename|
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
        puts "="
        puts "=  Almost done. Next steps you have to do yourself:"
        puts "=  -----------------------------------------------"
        puts "=  1 include the javascript file in your layout : \"= javascript_include_tag 'fancygrid'\""
        puts "=  2 include the stylesheet file in your layout : \"= stylesheet_link_tag 'fancygrid'\""
        puts "="
        puts "====================================================================="
      end
    end
  end
  
end