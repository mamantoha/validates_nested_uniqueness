# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = 'validates_nested_uniqueness'
  gem.version = '0.1.0'

  gem.summary = 'Library for validating nested uniqueness in Rails.'
  gem.author = 'Anton Maminov'
  gem.email = 'anton.maminov@gmail.com'
  gem.licenses = ['MIT']

  gem.files = [
    'lib/locales/en.yml',
    'lib/validates_nested_uniqueness'
  ]
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.6.0'

  gem.add_development_dependency('activerecord')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('sqlite3')
  gem.add_runtime_dependency('activemodel')
end
