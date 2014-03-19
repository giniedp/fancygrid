# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "fancygrid"
  gem.summary = %Q{Table rendering for rails applications}
  gem.description = %Q{Enables easy table rendering in rails applications}
  gem.email = "giniedp@online.de"
  gem.homepage = "http://github.com/giniedp/fancygrid"
  gem.authors = ["Alexander Graefenstein"]
end
Jeweler::RubygemsDotOrgTasks.new

#require 'rake/testtask'
#Rake::TestTask.new(:test) do |test|
#  test.libs << 'lib' << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#end
#
#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end
#
#task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "test #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
