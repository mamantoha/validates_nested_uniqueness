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
      expect(country.errors[:base].first).to eq('has already been taken')
    end

    it 'allows set nested attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'CA' }]

      expect(country).to be_valid
    end

    it 'allows duplicated nested case sensive attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'ny' }]

      expect(country).to be_valid
    end
  end

  context 'with case_sensitive' do
    let!(:country) { CountryWithCaseSensitive.new }

    it 'does not allow duplicated nested case sensive attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'ny' }]

      expect(country).not_to be_valid
    end
  end

  context 'with message' do
    let!(:country) { CountryWithMessage.new }

    it 'does not allow create with custom error message' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid
      expect(country.errors[:base].size).to eq(1)
      expect(country.errors[:base].first).to eq("City's name should be unique per country")
    end
  end
end
