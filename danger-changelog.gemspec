lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'changelog/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'danger-changelog'
  spec.version       = Changelog::VERSION
  spec.authors       = ['dblock']
  spec.email         = ['dblock@dblock.org']
  spec.description   = 'A danger.systems plugin that is OCD about your CHANGELOG.'
  spec.summary       = 'A danger.systems plugin that is OCD about your CHANGELOG.'
  spec.homepage      = 'https://github.com/dblock/danger-changelog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'danger-plugin-api', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
  spec.add_development_dependency 'listen', '3.0.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.4'
  spec.add_development_dependency 'rubocop', '~> 0.61.1'
  spec.add_development_dependency 'yard', '~> 0.9.11'
end
