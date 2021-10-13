# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/resources")
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'sqlite3'
require 'active_record'
require 'active_record/base'
require 'active_record/migration'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(
  'adapter' => 'sqlite3',
  'database' => ':memory:'
)

require File.join(File.dirname(__FILE__), '..', 'init')

autoload :Country, 'resources/country'
autoload :CountryWithCaseSensitive, 'resources/country_with_case_sensitive'
autoload :CountryWithMessage, 'resources/country_with_message'
autoload :CountryWithIndexErrors, 'resources/country_with_index_errors'
autoload :City, 'resources/city'
