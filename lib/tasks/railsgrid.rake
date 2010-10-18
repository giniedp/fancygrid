require 'ftools'
require 'pathname'
require 'rake'
require 'net/http'
require 'uri'

namespace :railsgrid do
  
  desc "generates needed railsgrid javascript"
  task :javascript => :environment do 

    js_source = File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'javascripts', 'railsgrid.js')
    js_target = Rails.root.join('public', 'javascripts', 'railsgrid.js')
    js_min = Rails.root.join('public', 'javascripts', 'railsgrid.min.js')
    
    puts "- Remove existing railsgrid javascripts"
    File.delete(js_target) if File.exists?(js_target)
    File.delete(js_min) if File.exists?(js_min)
    puts "- Copy railsgrid javascripts"
    File.open(js_target, 'w') do |f|
      File.open(js_source, "r") do |file|
        while (line = file.gets)
          f.print(line)
        end
      end
    end
  end
  
  desc "generates minified railsgrid javascript"
  task :javascript_min => [:environment, :javascript] do 
    
    js_source = File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'javascripts', 'railsgrid.js')
    js_target = Rails.root.join('public', 'javascripts', 'railsgrid.js')
    js_min = Rails.root.join('public', 'javascripts', 'railsgrid.min.js')
    
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
  
  desc "installs railsgrid"
  task :install => [:environment, :javascript] do

    # copy images
    FileUtils.mkdir_p(Pathname.new(Rails.public_path).join('images','railsgrid'))
    %w(add.png clear.png ddn.png dn.png first.png loading.gif magnifier.png next.png prev.png reloa.png th_bg.png up.png uup.png).each do |filename|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "app", "public", "images", "#{filename}")
      rails_path = Pathname.new(Rails.public_path).join('images','railsgrid',filename)
      File.copy(plugin_path, rails_path)
    end
    
    # copy stylesheet
    FileUtils.mkdir_p(Pathname.new(Rails.public_path).join('stylesheets'))
    %w(railsgrid.css).each do |filename|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "app", "public", "stylesheets", "#{filename}")
      rails_path = Pathname.new(Rails.public_path).join('stylesheets', filename)
      File.copy(plugin_path, rails_path)
    end
    
    # copy locales
    %w(de en).each do |locale|
      plugin_path = File.join(File.dirname(__FILE__), "..", "..", "config", "locales", "railsgrid.#{locale}.yml")
      rails_path = Pathname.new(Rails.root).join('config','locales',"railsgrid.#{locale}.yml")
      File.copy(locale_plugin_path, locale_rails_path)
    end
  end
end