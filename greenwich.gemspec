# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "greenwich/version"

Gem::Specification.new do |s|
  s.rubygems_version  = '1.4.2'

  s.name              = "greenwich"
  s.rubyforge_project = "greenwich"

  s.version           = Greenwich::VERSION
  s.platform          = Gem::Platform::RUBY

  s.authors           = ["thekompanee", "jfelchner"]
  s.email             = ["support@thekompanee.com"]
  s.homepage          = "http://github.com/jfelchner/greenwich"

  s.summary           = %q{Allowing users to select dates with custom time zones since 2011.}
  s.description       = %q{Store all of your times in the database as UTC but want to give your users the ability to choose a custom time zone for each instance of a DateTime field?}

  s.rdoc_options      = ["--charset = UTF-8"]
  s.extra_rdoc_files  = %w[README.md LICENSE]

  #= Manifest =#
  s.files             = `git ls-files`.split("\n")
  s.test_files        = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables       = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths     = ["lib"]
  #= Manifest =#

  s.add_dependency('activerecord',  '~> 3.0')
  s.add_dependency('activesupport', '~> 3.0')
  s.add_dependency('tzinfo',        '~> 0.3')

  s.add_development_dependency('bundler',   '~> 1.0')
  s.add_development_dependency('rspec',     '~> 2.6')
  s.add_development_dependency('yard',      '~> 0.7')
  s.add_development_dependency('sqlite3',   '~> 1.3')
  s.add_development_dependency('pry')
end
