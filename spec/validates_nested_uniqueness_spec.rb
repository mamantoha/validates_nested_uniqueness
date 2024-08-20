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
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid

      if ActiveModel.version < Gem::Version.new('6.1.0')
        expect(country.errors.size).to eq(1)
        expect(country.errors.first).to eq([:cities, 'has already been taken'])
        expect(country.errors.full_messages).to eq(['Cities has already been taken'])
      else
        expect(country.errors.size).to eq(1)
        expect(country.errors.first.message).to eq('has already been taken')
        expect(country.errors.full_messages).to eq(['Cities name has already been taken'])
      end
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

      expect(country.errors.size).to eq(1)

      if ActiveModel.version < Gem::Version.new('6.1.0')
        expect(country.errors.first).to eq([:cities, 'should be unique per country'])
        expect(country.errors.full_messages).to eq(['Cities should be unique per country'])
      else
        expect(country.errors.first.message).to eq('should be unique per country')
        expect(country.errors.full_messages).to eq(['Cities name should be unique per country'])
      end
    end
  end

  context 'with index errors' do
    let!(:country) { CountryWithIndexErrors.new }

    it 'errors should be indexed' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid

      if ActiveModel.version < Gem::Version.new('6.1.0')
        expect(country.errors.size).to eq(1)
        expect(country.errors.first).to eq([:cities, 'has already been taken'])
        expect(country.errors.full_messages).to eq(
          ['Cities has already been taken']
        )
      else
        expect(country.errors.size).to eq(2)
        expect(country.errors.first.message).to eq('has already been taken')
        expect(country.errors.full_messages).to eq(
          ['Cities[1] name has already been taken', 'Cities[2] name has already been taken']
        )
      end
    end
  end
end
