# -*- encoding: utf-8 -*-
require File.expand_path('../lib/three/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'three'
  s.version     = Three::VERSION
  s.date        = '2014-06-16'
  s.summary     = "three"
  s.description = "Even simpler authorization gem"
  s.authors     = ["Darren Cauthon"]
  s.email       = 'darren@cauthon.com'
  s.files       = ["lib/three.rb"]
  s.homepage    = 'https://github.com/darrencauthon/three'

  s.add_development_dependency 'mocha'
  s.add_development_dependency 'rake'
end
