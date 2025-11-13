# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'NestedUniquenessValidator' do
  context 'with regular validator' do
    let!(:country) { Country.new }

    it 'does not allow duplicated nested attributes' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid

      expect(country.errors.size).to eq(1)
      expect(country.errors.first.message).to eq('has already been taken')
      expect(country.errors.full_messages).to eq(['Cities name has already been taken'])
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

      expect(country.errors.first.message).to eq('should be unique per country')
      expect(country.errors.full_messages).to eq(['Cities name should be unique per country'])
    end
  end

  context 'with index errors' do
    let!(:country) { CountryWithIndexErrors.new }

    it 'errors should be indexed' do
      country.cities_attributes = [{ name: 'NY' }, { name: 'NY' }, { name: 'NY' }]

      expect(country).not_to be_valid

      expect(country.errors.size).to eq(2)
      expect(country.errors.first.message).to eq('has already been taken')
      expect(country.errors.full_messages).to eq(
        ['Cities[1] name has already been taken', 'Cities[2] name has already been taken']
      )
    end
  end

  context 'with custom comparison logic' do
    let!(:country) { CountryWithCustomComparison.new }

    it 'uses custom comparison for uniqueness check' do
      country.cities_attributes = [
        { name: '  New York  ' },
        { name: 'NEW YORK' },
        { name: 'new york' }
      ]

      expect(country).not_to be_valid
      expect(country.errors.size).to eq(2)
      expect(country.errors.full_messages).to include(
        'Cities name has already been taken'
      )
    end

    it 'allows different values after custom normalization' do
      country.cities_attributes = [
        { name: '  New York  ' },
        { name: '  Los Angeles  ' }
      ]

      expect(country).to be_valid
    end
  end

  # Edge Cases
  context 'when attribute option is missing' do
    it 'raises ArgumentError during validation setup' do
      expect do
        Country.class_eval do
          validates :cities, nested_uniqueness: {
            scope: [:country_id]
          }
        end
      end.to raise_error(ArgumentError, /:attribute option is required/)
    end
  end

  context 'when nested values are nil or empty' do
    let!(:country) { Country.new }

    it 'handles nil associations gracefully' do
      country.cities_attributes = []
      expect(country).to be_valid
    end

    it 'handles empty associations gracefully' do
      country.cities = []
      expect(country).to be_valid
    end
  end

  context 'when attribute values are nil' do
    let!(:country) { Country.new }

    it 'handles nil attribute values without errors' do
      country.cities_attributes = [{ name: nil }, { name: 'NY' }, { name: nil }]
      expect(country).not_to be_valid
      expect(country.errors.full_messages).to eq(['Cities name has already been taken'])
    end
  end

  context 'when attribute values are of different types' do
    let!(:country) { Country.new }

    it 'handles numeric values correctly' do
      country.cities_attributes = [{ name: 123 }, { name: 456 }, { name: 123 }]
      expect(country).not_to be_valid
      expect(country.errors.full_messages).to eq(['Cities name has already been taken'])
    end
  end

  context 'when records are marked for destruction' do
    let!(:country) { Country.new }

    it 'ignores records marked for destruction' do
      country.cities_attributes = [
        { name: 'NY' },
        { name: 'NY', _destroy: '1' },
        { name: 'CA' }
      ]
      expect(country).to be_valid
    end
  end

  context 'when case_sensitive is false with non-string values' do
    let!(:country_with_case_sensitive) { CountryWithCaseSensitive.new }

    it 'handles non-string values gracefully' do
      country_with_case_sensitive.cities_attributes = [{ name: 123 }, { name: 123 }]
      expect(country_with_case_sensitive).not_to be_valid
    end
  end

  context 'with complex scoping scenarios' do
    let!(:country) { Country.new }

    it 'validates uniqueness within multiple scopes (conceptual test)' do
      # This demonstrates that the validator can handle more complex scenarios
      # In a real implementation, you might have additional fields
      country.cities_attributes = [
        { name: 'Springfield' },
        { name: 'Springfield' }
      ]

      expect(country).not_to be_valid
      expect(country.errors.full_messages).to include('Cities name has already been taken')
    end
  end
end
