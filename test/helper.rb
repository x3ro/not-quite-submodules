require 'rubygems'
require 'fileutils'


require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end


require 'minitest/unit'
require "minitest/reporters"
MiniTest::Reporters.use! MiniTest::Reporters::SpecReporter.new


require 'simplecov'
SimpleCov.start


$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'not-quite-submodules'

module NQS
  class TestCaseWithTempdir < MiniTest::Unit::TestCase
    def setup
      @tmpdir ||= "#{Dir.pwd}/temp/"
      if Dir.exists? @tmpdir
        raise "Temporary directory #{@tmpdir} already exists. Please delete it :)"
      else
        Dir.mkdir @tmpdir
      end
    end

    def teardown
      FileUtils.rm_r @tmpdir
    end
  end
end


MiniTest::Unit.autorun
