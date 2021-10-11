# frozen_string_literal: true

require 'active_model'

module ActiveRecord
  module Validations
    # ::nodoc
    class NestedUniquenessValidator < ActiveModel::EachValidator
      def initialize(options)
        unless Array(options[:scope]).all? { |scope| scope.respond_to?(:to_sym) }
          raise ArgumentError, "#{options[:scope]} is not supported format for :scope option. " \
            'Pass a symbol or an array of symbols instead: `scope: :user_id`'
        end

        super

        @column = options[:column]
        @case_sensitive = options[:case_sensitive]
        @scope = options[:scope] || []
        @error_key = options[:error_key] || :taken
        @message = options[:message] || nil
      end

      def validate_each(record, _attribute, value)
        dupes = Set.new

        value.reject(&:marked_for_destruction?).map do |nested_val|
          dupe = @scope.each.each_with_object({}) do |(k), memo|
            memo[k] = nested_val.try(k)
          end
          dupe[@column] = nested_val.try(@column)
          dupe[@column] = dupe[@column].try(:downcase) if @case_sensitive == false

          if dupes.member?(dupe)
            record.errors.add(:base, @error_key, message: @message)
          else
            dupes.add(dupe)
          end
        end
      end
    end

    module ClassMethods
      # Validates whether associations are uniqueness when using accepts_nested_attributes_for.
      # Useful for making sure that only one city of the country
      # can be named "NY".
      #
      #   class City < ActiveRecord::Base
      #     belongs_to :country
      #   end
      #
      #   class Country < ActiveRecord::Base
      #     has_many :cities, dependent: :destroy
      #     accepts_nested_attributes_for :cities, allow_destroy: true
      #
      #     validates :cities, nested_uniqueness: {
      #       column: :name,
      #       scope: [:country_id],
      #       case_sensitive: false
      #     }
      #   end
      #
      #   country = Country.new(name: 'US', cities: [City.new(name: 'NY'), City.new(name: 'NY')])
      #
      # Configuration options:
      # * <tt>:column</tt> - Specify the column of associated model to validate.
      # * <tt>:scope</tt> - One or more columns by which to limit the scope of
      #   the uniqueness constraint.
      # * <tt>:case_sensitive</tt> - Looks for an exact match. Ignored by
      #   non-text columns (+true+ by default).
      # * <tt>:message</tt> - A custom error message (default is: "has already been taken").
      # * <tt>:error_key</tt> - A custom error key to use (default is: :nested_taken).
      def validates_nested_uniqueness_of(*attr_names)
        validates_with NestedUniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
