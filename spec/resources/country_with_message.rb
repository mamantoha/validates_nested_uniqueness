# frozen_string_literal: true

class CountryWithMessage < ActiveRecord::Base
  self.table_name = 'countries'

  has_many :cities, dependent: :destroy, foreign_key: :country_id
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    column: :name,
    scope: [:country_id],
    message: "City's name should be unique per country"
  }
end
