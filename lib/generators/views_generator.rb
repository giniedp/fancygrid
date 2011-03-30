module Fancygrid
  module Generators#:nodoc:
    
    class ViewsGenerator < Rails::Generators::Base#:nodoc:

      def copy_views
        %w(controls list_frame table_frame search sort).each do |name|
          plugin_path = File.join(File.dirname(__FILE__), "../../app/views/fancygrid/base/#{name}.html.haml")
          rails_path = Rails.root.join("app/views/fancygrid/base/#{name}.html.haml")
          copy_file(plugin_path, rails_path)
        end
      end

      def print_info
        puts "====================================================================="
        puts ""
        puts "  Views have been copied to #{Rails.root.join('app/views/fancygrid/base')} "
        puts "  You can modify them as you wish"
        puts ""
        puts "====================================================================="
      end
    end
  end
  
end