# frozen_string_literal: true

class City < ActiveRecord::Base
  belongs_to :country, foreign_key: :country_id
end
