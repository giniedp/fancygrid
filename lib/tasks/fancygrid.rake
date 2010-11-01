require 'ftools'
require 'pathname'
require 'rake'
require 'net/http'
require 'uri'

namespace :fancygrid do
  
  desc "generates needed fancygrid javascript"
  task :javascript => :environment do 

    js_source = File.join(File.dirname(__FILE__), '..', '..', 'public', 'javascripts', 'fancygrid.js')
    js_target = Rails.root.join('public', 'javascripts', 'fancygrid.js')
    js_min = Rails.root.join('public', 'javascripts', 'fancygrid.min.js')
    
    puts "- Remove existing fancygrid javascripts"
    File.delete(js_target) if File.exists?(js_target)
    File.delete(js_min) if File.exists?(js_min)
    puts "- Copy fancygrid javascripts"
    File.open(js_target, 'w') do |f|
      File.open(js_source, "r") do |file|
        while (line = file.gets)
          f.print(line)
        end
      end
    end
  end
  
  desc "generates minified fancygrid javascript"
  task :javascript_min => [:environment, :javascript] do 
    
    js_source = File.join(File.dirname(__FILE__), '..', '..', 'public', 'javascripts', 'fancygrid.js')
    js_target = Rails.root.join('public', 'javascripts', 'fancygrid.js')
    js_min = Rails.root.join('public', 'javascripts', 'fancygrid.min.js')
    
    lines = []
    File.open(js_target, 'r') do |f|
      while (line = f.gets)
        lines << line
      end
    end
    
    puts "- Minify javascript using 'http://closure-compiler.appspot.com/compile'"
    
    url = URI.parse('http://closure-compiler.appspot.com/compile')
    req = Net::HTTP::Post.new(url.path)
    req.set_form_data({
      :compilation_level => "SIMPLE_OPTIMIZATIONS",
      :output_format => "text",
      :output_info => "compiled_code",
      :js_code => lines.join("")
    })
    res = Net::HTTP.new(url.host, url.port).start {|http| http.request(req) }
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      File.delete(js_target) if File.exists?(js_target)
      File.delete(js_min) if File.exists?(js_min)
      File.open(js_min, 'w') do |f|
        f.print(res.body)
      end
      puts "- Javascript minified to #{js_min}"
    else
      puts "- Error during google closure request"
    end
  end
  
  desc "installs fancygrid"
  task :install => [:environment, :javascript] do

    puts "- Copy images"
    FileUtils.mkdir_p(Pathname.new(Rails.public_path).join('images','fancygrid'))
    %w(add.png clear.png ddn.png dn.png first.png loading.gif magnifier.png next.png prev.png reload.png th_bg.png up.png uup.png spacer.gif).each do |filename|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "public", "images", "fancygrid", "#{filename}")
      rails_path = Pathname.new(Rails.public_path).join('images','fancygrid',filename)
      File.copy(plugin_path, rails_path) unless File.exists? rails_path
    end
    
    puts "- Copy stylesheets"
    FileUtils.mkdir_p(Pathname.new(Rails.public_path).join('stylesheets'))
    %w(fancygrid.css).each do |filename|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "public", "stylesheets", "#{filename}")
      rails_path = Pathname.new(Rails.public_path).join('stylesheets', filename)
      File.copy(plugin_path, rails_path) unless File.exists? rails_path
    end
    
    puts "- Copy locales"
    %w(de en).each do |locale|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "config", "locales", "fancygrid.#{locale}.yml")
      rails_path = Pathname.new(Rails.root).join('config','locales',"fancygrid.#{locale}.yml")
      File.copy(plugin_path, rails_path) unless File.exists? rails_path
    end
    
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