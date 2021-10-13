# frozen_string_literal: true

class CountryWithCaseSensitive < ActiveRecord::Base
  self.table_name = 'countries'

  has_many :cities, dependent: :destroy, foreign_key: :country_id
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    attribute: :name,
    scope: [:country_id],
    case_sensitive: false
  }
end
