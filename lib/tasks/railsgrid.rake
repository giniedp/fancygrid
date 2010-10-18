require 'rake'
require 'net/http'
require 'uri'

js_source = File.join(File.dirname(__FILE__), '..', '..', 'app', 'public', 'javascripts', 'railsgrid.js')
js_target = Rails.root.join('public', 'javascripts', 'railsgrid.js')
js_min = Rails.root.join('public', 'javascripts', 'railsgrid.min.js')
    
namespace :railsgrid do
  
  desc "generates needed railsgrid javascript"
  task :javascript => :environment do 
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
end