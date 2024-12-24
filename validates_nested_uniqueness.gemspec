# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = 'validates_nested_uniqueness'
  gem.version = '1.1.0'

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
  gem.required_ruby_version = '>= 3.1.0'

  gem.add_dependency('activemodel', '>= 6.1.0')

  gem.add_development_dependency('activerecord', '>= 6.1.0')
  gem.add_development_dependency('rspec', '>= 3.0.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
