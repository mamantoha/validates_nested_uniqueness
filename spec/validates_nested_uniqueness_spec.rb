# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Nested uniqueness validation' do
  before(:all) do
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

  after(:all) do
    ActiveRecord::Base.connection.drop_table(:countries)
    ActiveRecord::Base.connection.drop_table(:cities)
  end

  context 'with regular validator' do
    let!(:country) { Country.new }

    it 'does not allow duplicated nested attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid
      expect(country.errors[:base].size).to eq(1)
      expect(country.errors[:base].first).to eq('Please choose unique values.')
    end

    it 'allows set nested attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'CA' }]

      expect(country).to be_valid
    end
  end
end
