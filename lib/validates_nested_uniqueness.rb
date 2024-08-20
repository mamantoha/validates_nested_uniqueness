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

        @attribute_name = options[:attribute]
        @case_sensitive = options[:case_sensitive]
        @scope = options[:scope] || []
        @error_key = options[:error_key] || :taken
        @message = options[:message] || nil
      end

      def validate_each(record, association_name, value)
        track_values = Set.new

        reflection =
          if ActiveModel.version >= Gem::Version.new('7.2.0')
            record._reflections[association_name]
          else
            record._reflections[association_name.to_s]
          end

        indexed_attribute = reflection.options[:index_errors] || ActiveRecord::Base.try(:index_nested_attribute_errors)

        value.reject(&:marked_for_destruction?).select(&:changed_for_autosave?).map.with_index do |nested_value, index|
          normalized_attribute = normalize_attribute(association_name, indexed_attribute: indexed_attribute,
                                                                       index: index)

          track_value = @scope.each.each_with_object({}) do |k, memo|
            memo[k] = nested_value.try(k)
          end

          track_value[@attribute_name] = nested_value.try(@attribute_name)
          track_value[@attribute_name] = track_value[@attribute_name].try(:downcase) if @case_sensitive == false

          if track_values.member?(track_value)
            inner_error = ActiveModel::Error.new(
              nested_value,
              @attribute_name,
              @error_key,
              value: nested_value[@attribute_name],
              message: @message
            )

            error = ActiveModel::NestedError.new(record, inner_error, attribute: normalized_attribute)

            record.errors.import(error)
          else
            track_values.add(track_value)
          end
        end
      end

      private

      def normalize_attribute(association_name, indexed_attribute: false, index: nil)
        if indexed_attribute
          "#{association_name}[#{index}].#{@attribute_name}"
        else
          "#{association_name}.#{@attribute_name}"
        end
      end
    end

    # :nodoc:
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
      #       attribute: :name,
      #       scope: [:country_id],
      #       case_sensitive: false
      #     }
      #   end
      #
      #   country = Country.new(name: 'US', cities: [City.new(name: 'NY'), City.new(name: 'NY')])
      #
      # Configuration options:
      # * <tt>:attribute</tt> - Specify the attribute name of associated model to validate.
      # * <tt>:scope</tt> - One or more columns by which to limit the scope of
      #   the uniqueness constraint.
      # * <tt>:case_sensitive</tt> - Looks for an exact match. Ignored by
      #   non-text columns (+true+ by default).
      # * <tt>:message</tt> - A custom error message (default is: "has already been taken").
      # * <tt>:error_key</tt> - A custom error key to use (default is: :taken).
      def validates_nested_uniqueness_of(*attr_names)
        validates_with NestedUniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
