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
  gem.name = "not-quite-submodules"
  gem.homepage = "http://github.com/x3ro/not-quite-submodules"
  gem.license = "MIT"
  gem.summary = %Q{This gem can be used to automatically clone and update a git repository.}
  gem.description = %Q{This gem can be used to automatically clone an update a git repository, relying on tags to see if a newer version of the repository is available.}
  gem.email = "lucas@x3ro.de"
  gem.authors = ["Lucas Jenss"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'reek/rake/task'
Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.verbose = false
  t.source_files = 'lib/**/*.rb'
end

require 'yard'
YARD::Rake::YardocTask.new
