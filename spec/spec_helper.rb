# frozen_string_literal: true

$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH.unshift("#{File.dirname(__FILE__)}/resources")
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
require 'sqlite3'
require 'logger'
require 'active_record'
require 'active_record/base'
require 'active_record/migration'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.establish_connection(
  'adapter' => 'sqlite3',
  'database' => ':memory:'
)

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Schema.define(version: 1) do
      create_table :countries, force: true do |t|
        t.column :name, :string
      end

      create_table :cities, force: true do |t|
        t.belongs_to :country
        t.column :name, :string
      end
    end
  end

  config.after(:suite) do
    ActiveRecord::Base.connection.drop_table(:countries)
    ActiveRecord::Base.connection.drop_table(:cities)
  end
end

require File.join(File.dirname(__FILE__), '..', 'init')

autoload :Country, 'resources/country'
autoload :CountryWithCaseSensitive, 'resources/country_with_case_sensitive'
autoload :CountryWithMessage, 'resources/country_with_message'
autoload :CountryWithIndexErrors, 'resources/country_with_index_errors'
autoload :CountryWithCustomComparison, 'resources/country_with_custom_comparison'
autoload :City, 'resources/city'
