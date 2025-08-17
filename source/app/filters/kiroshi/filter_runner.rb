# frozen_string_literal: true

module Kiroshi
  # @author darthjee
  #
  # A filter runner that applies filtering logic to ActiveRecord scopes
  #
  # This class handles the actual application of filter logic to database queries,
  # supporting both exact matches and partial matches using SQL LIKE operations.
  # It separates the filter configuration from the filter execution logic.
  #
  # @example Creating and running a filter
  #   filter = Kiroshi::Filter.new(:name, match: :like)
  #   runner = Kiroshi::FilterRunner.new(filter: filter, scope: User.all, filters: { name: 'John' })
  #   result = runner.apply
  #
  # @since 0.1.0
  class FilterRunner
    # Creates a new FilterRunner instance
    #
    # @param filter [Kiroshi::Filter] the filter configuration
    # @param scope [ActiveRecord::Relation] the scope to filter
    # @param filters [Hash] a hash containing filter values
    #
    # @since 0.1.0
    def initialize(filter:, scope:, filters:)
      @filter = filter
      @scope = scope
      @filters = filters
    end

    # Applies the filter logic to the scope
    #
    # This method contains the actual filtering logic, checking the filter's
    # match type and applying the appropriate WHERE clause to the scope.
    #
    # @return [ActiveRecord::Relation] the filtered scope
    #
    # @example Applying exact match filter
    #   runner = FilterRunner.new(filter: filter, scope: scope, filters: { name: 'John' })
    #   runner.apply
    #
    # @example Applying LIKE filter
    #   runner = FilterRunner.new(filter: filter, scope: scope, filters: { title: 'Ruby' })
    #   runner.apply
    #
    # @example With no matching value
    #   runner = FilterRunner.new(filter: filter, scope: scope, filters: { name: nil })
    #   runner.apply
    #   # Returns the original scope unchanged
    #
    # @since 0.1.1
    def apply
      filter_value = filters[filter.attribute]
      return scope unless filter_value.present?

      case filter.match
      when :like
        scope.where("#{filter.attribute} LIKE ?", "%#{filter_value}%")
      else # :exact (default)
        scope.where(filter.attribute => filter_value)
      end
    end

    private

    attr_reader :filter, :scope, :filters

    delegate :attribute, :match, to: :filter

    # @!method attribute
    #   @api private
    #   @private
    #
    #   Returns the attribute name to filter by
    #
    #   @return [Symbol] the attribute name to filter by

    # @!method match
    #   @api private
    #   @private
    #
    #   Returns the matching type (+:exact+ or +:like+)
    #
    #   @return [Symbol] the matching type (+:exact+ or +:like+)
  end
end