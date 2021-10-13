# frozen_string_literal: true

class CountryWithIndexErrors < ActiveRecord::Base
  self.table_name = 'countries'

  has_many :cities, dependent: :destroy, foreign_key: :country_id, index_errors: true
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    attribute: :name,
    scope: [:country_id]
  }
end
