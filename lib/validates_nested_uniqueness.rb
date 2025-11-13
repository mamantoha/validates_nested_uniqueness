# frozen_string_literal: true

require 'logger'
require 'active_model'

module ActiveRecord
  module Validations
    # ::nodoc
    class NestedUniquenessValidator < ActiveModel::EachValidator
      def initialize(options)
        unless options[:attribute]
          raise ArgumentError, ':attribute option is required. ' \
                               'Specify the attribute name to validate: `attribute: :name`'
        end

        unless Array(options[:scope]).all? { |scope| scope.respond_to?(:to_sym) }
          raise ArgumentError, "#{options[:scope]} is not supported format for :scope option. " \
                               'Pass a symbol or an array of symbols instead: `scope: :user_id`'
        end

        if options[:comparison] && !options[:comparison].respond_to?(:call)
          raise ArgumentError, ':comparison option must be a callable object (Proc or lambda)'
        end

        super

        @attribute_name = options[:attribute]
        @case_sensitive = options[:case_sensitive]
        @scope = options[:scope] || []
        @error_key = options[:error_key] || :taken
        @message = options[:message] || nil
        @comparison = options[:comparison]
      end

      def validate_each(record, association_name, value)
        return if value.blank? || !value.respond_to?(:reject)

        track_values = Set.new

        reflection = record.class.reflections[association_name.to_s]
        return unless reflection

        indexed_attribute = reflection.options[:index_errors] || ActiveRecord::Base.try(:index_nested_attribute_errors)

        value.reject(&:marked_for_destruction?).select(&:changed_for_autosave?).each_with_index do |nested_value, index|
          next unless nested_value.respond_to?(@attribute_name)

          normalized_attribute = normalize_attribute(association_name, indexed_attribute:, index:)

          track_value = build_track_value(nested_value)

          if track_values.member?(track_value)
            add_validation_error(record, nested_value, normalized_attribute)
          else
            track_values.add(track_value)
          end
        end
      end

      private

      def build_track_value(nested_value)
        track_value = @scope.each_with_object({}) do |scope_key, memo|
          memo[scope_key] = nested_value.try(scope_key)
        end

        attribute_value = nested_value.try(@attribute_name)
        track_value[@attribute_name] = normalize_value(attribute_value)
        track_value
      end

      def normalize_value(value)
        return value if value.nil?
        return @comparison.call(value) if @comparison
        return value if @case_sensitive != false
        return value unless value.respond_to?(:downcase)

        value.downcase
      end

      def add_validation_error(record, nested_value, normalized_attribute)
        inner_error = ActiveModel::Error.new(
          nested_value,
          @attribute_name,
          @error_key,
          value: nested_value[@attribute_name],
          message: @message
        )

        error = ActiveModel::NestedError.new(record, inner_error, attribute: normalized_attribute)
        record.errors.import(error)
      end

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
      #
      # This validator ensures that nested attributes maintain uniqueness constraints
      # within the scope of their parent record and any additional specified scopes.
      #
      # @example Basic usage
      #   class Country < ActiveRecord::Base
      #     has_many :cities, dependent: :destroy
      #     accepts_nested_attributes_for :cities, allow_destroy: true
      #
      #     validates :cities, nested_uniqueness: {
      #       attribute: :name,
      #       scope: [:country_id]
      #     }
      #   end
      #
      # @example With case-insensitive validation
      #   validates :cities, nested_uniqueness: {
      #     attribute: :name,
      #     scope: [:country_id],
      #     case_sensitive: false
      #   }
      #
      # @example With custom error message
      #   validates :cities, nested_uniqueness: {
      #     attribute: :name,
      #     scope: [:country_id],
      #     message: "must be unique within this country"
      #   }
      #
      # @example With custom comparison logic
      #   validates :cities, nested_uniqueness: {
      #     attribute: :name,
      #     scope: [:country_id],
      #     comparison: ->(value) { value.to_s.strip.downcase }
      #   }
      #
      # Configuration options:
      # * <tt>:attribute</tt> - (Required) Specify the attribute name of associated model to validate.
      # * <tt>:scope</tt> - One or more columns by which to limit the scope of
      #   the uniqueness constraint. Can be a symbol or array of symbols.
      # * <tt>:case_sensitive</tt> - Looks for an exact match. Ignored by
      #   non-text columns (+true+ by default).
      # * <tt>:message</tt> - A custom error message (default is: "has already been taken").
      # * <tt>:error_key</tt> - A custom error key to use (default is: +:taken+).
      # * <tt>:comparison</tt> - A callable object (Proc/lambda) for custom value comparison logic.
      def validates_nested_uniqueness_of(*attr_names)
        validates_with NestedUniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
