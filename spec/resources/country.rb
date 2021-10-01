# frozen_string_literal: true

class Country < ActiveRecord::Base
  has_many :cities, dependent: :destroy
  accepts_nested_attributes_for :cities, allow_destroy: true

  validates :cities, nested_uniqueness: {
    column: :name,
    scope: [:country_id],
    case_sensitive: false
  }
end
