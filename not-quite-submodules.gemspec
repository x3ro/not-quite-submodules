# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "not-quite-submodules"
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Lucas Jenss"]
  s.date = "2013-04-05"
  s.description = "This gem can be used to automatically clone an update a git repository, relying on tags to see if a newer version of the repository is available."
  s.email = "lucas@x3ro.de"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/not-quite-submodules.rb",
    "not-quite-submodules.gemspec"
  ]
  s.homepage = "http://github.com/x3ro/not-quite-submodules"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "This gem can be used to automatically clone and update a git repository."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<versionomy>, ["~> 0.4.4"])
      s.add_development_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_development_dependency(%q<yard>, ["~> 0.7"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.2.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<reek>, ["~> 1.2.8"])
    else
      s.add_dependency(%q<versionomy>, ["~> 0.4.4"])
      s.add_dependency(%q<rspec>, ["~> 2.8.0"])
      s.add_dependency(%q<yard>, ["~> 0.7"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.2.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<reek>, ["~> 1.2.8"])
    end
  else
    s.add_dependency(%q<versionomy>, ["~> 0.4.4"])
    s.add_dependency(%q<rspec>, ["~> 2.8.0"])
    s.add_dependency(%q<yard>, ["~> 0.7"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.2.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.4"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<reek>, ["~> 1.2.8"])
  end
end

