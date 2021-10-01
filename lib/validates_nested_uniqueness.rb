# frozen_string_literal: true

require 'active_model'
require 'active_support/i18n'
I18n.load_path += Dir["#{File.dirname(__FILE__)}/locale/*.yml"]

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

        @watch = options[:watch]
        @case_sensitive = options[:case_sensitive]
        @scope = options[:scope] || []
        @error_key = options[:error_key] || :nested_taken
        @message = options[:message] || nil
      end

      def validate_each(record, _attribute, value)
        dupes = Set.new

        value.reject(&:marked_for_destruction?).map do |nested_val|
          dupe = @scope.each.each_with_object({}) do |(k), memo|
            memo[k] = nested_val.try(k)
          end
          dupe[@watch] = nested_val.try(@watch)
          dupe[@watch] = dupe[@watch].try(:downcase) if @case_sensitive == false

          if dupes.member?(dupe)
            record.errors.add(:base, @error_key, message: @message)
          else
            dupes.add(dupe)
          end
        end
      end
    end

    module ClassMethods
      def validates_nested_uniqueness_of(*attr_names)
        validates_with NestedUniquenessValidator, _merge_attributes(attr_names)
      end
    end
  end
end
