# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-xcov'
  spec.version       = DangerXcov::VERSION
  spec.authors       = ['Carlos Vidal']
  spec.email         = ['nakioparkour@gmail.com']
  spec.description   = %q{Danger plugin to validate the code coverage of the files changed.}
  spec.summary       = %q{Danger plugin to validate the code coverage of the files changed}
  spec.homepage      = 'https://github.com/fastlane-community/danger-xcov'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_dependency 'danger', '>= 2.1'
  spec.add_dependency 'xcov', '>= 1.1.2'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
