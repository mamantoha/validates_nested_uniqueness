# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

platforms :ruby do
  gem 'sqlite3', '>= 2.1'
end

gem 'activemodel', '>= 6.1.0'

group :development do
  gem 'activerecord', '>= 6.1.0'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'ruby-lsp', require: false
end

group :test do
  gem 'rspec', '>= 3.0.0'
end
