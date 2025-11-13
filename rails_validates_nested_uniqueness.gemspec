# frozen_string_literal: true

Gem::Specification.new do |gem|
  gem.name = 'rails_validates_nested_uniqueness'
  gem.version = '1.3.0'

  gem.summary = 'Rails library for validating nested uniqueness with accepts_nested_attributes_for.'
  gem.author = 'Anton Maminov'
  gem.email = 'anton.maminov@gmail.com'
  gem.homepage = 'https://github.com/mamantoha/validates_nested_uniqueness'
  gem.licenses = ['MIT']

  gem.description = 'Validates whether associations are uniqueness when using accepts_nested_attributes_for.'

  gem.files = [
    'README.md',
    'LICENSE',
    'CHANGELOG.md',
    'lib/validates_nested_uniqueness.rb'
  ]
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 3.2.0'

  gem.add_dependency('activemodel', '>= 7.2.0')

  gem.add_development_dependency('activerecord', '>= 7.2.0')
  gem.add_development_dependency('rspec', '>= 3.12.0')
  gem.metadata['rubygems_mfa_required'] = 'true'
end
