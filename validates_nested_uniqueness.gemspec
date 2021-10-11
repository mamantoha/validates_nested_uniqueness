# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = 'validates_nested_uniqueness'
  gem.version = '0.1.0'

  gem.summary = 'Library for validating nested uniqueness in Rails.'
  gem.author = 'Anton Maminov'
  gem.email = 'anton.maminov@gmail.com'
  gem.homepage = 'https://github.com/mamantoha/validates_nested_uniqueness'
  gem.licenses = ['MIT']

  gem.files = [
    'README.md',
    'LICENSE',
    'lib/validates_nested_uniqueness.rb'
  ]
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.6.0'

  gem.add_runtime_dependency('activemodel', '>= 4.1.0')

  gem.add_development_dependency('activerecord', '>= 4.1.0')
  gem.add_development_dependency('rspec', '>= 3.0.0')
end
