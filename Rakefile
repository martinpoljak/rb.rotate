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
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rb.rotate"
  gem.homepage = "http://github.com/martinkozak/rb.rotate"
  gem.license = "MIT"
  #gem.summary = %Q{TODO: one-line summary of your gem}
  gem.summary = %Q{some text}
  #gem.description = %Q{TODO: longer description of your gem}
  gem.email = "martinkozak@martinkozak.net"
  gem.authors = ["Martin Kozák"]
  gem.executables = ["rb.rotate"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  # gem.add_runtime_dependency 'sys-uname', '>= 0.8.5'
  # gem.add_runtime_dependency 'pony', '>= 1.1'
  # gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "rb.rotate #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
