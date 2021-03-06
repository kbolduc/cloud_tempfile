# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

require "cloud_tempfile/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cloud_tempfile"
  s.version     = CloudTempfile::VERSION
  s.date        = "2016-04-06"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Kevin Bolduc"]
  s.email       = ["kevin.bolduc@gmail.com"]
  s.homepage    = "http://github.com/kbolduc/cloud_tempfile"
  s.summary     = %q{Tempfile creation directly on cloud storage (S3, Google, Rackspace etc] which can be utilized in a Ruby application}
  s.description = %q{Tempfile creation directly on cloud storage (S3, Google, Rackspace etc] which can be utilized in a Ruby application}
  s.license     = 'MIT'

  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  # rubyforge
  s.rubyforge_project = "cloud_tempfile"

  s.add_dependency 'fog', '~> 1.36'
  s.add_dependency 'activemodel'
  s.add_dependency 'mime-types', '<= 2.99.1'

  s.add_development_dependency 'bundler', '~> 1.17'
  s.add_development_dependency 'rake', '~> 11.3'
  s.add_development_dependency 'rdoc', '>= 0'
  s.add_development_dependency 'builder', '>= 0'
  s.add_development_dependency 'rspec', '~> 2.99', '< 3'
  s.add_development_dependency 'jeweler', '>= 2.1.1'
  s.add_development_dependency 'appraisal', '>= 0'

  #s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  #s.test_files = Dir["{test,spec,features}/**/*"]
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
