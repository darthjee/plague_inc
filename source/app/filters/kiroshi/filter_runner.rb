# frozen_string_literal: true

module Kiroshi
  # @api private
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
      return scope unless filter_value.present?

      query_strategy = FilterQuery.for(filter.match).new(self)
      query_strategy.apply
    end

    # Returns the filter value for the current filter's attribute
    #
    # @return [Object, nil] the filter value or nil if not present
    #
    # @since 0.1.1
    def filter_value
      filters[filter.attribute]
    end

    # Returns the current scope being filtered
    #
    # @return [ActiveRecord::Relation] the scope
    #
    # @since 0.1.1
    attr_reader :scope

    # Returns the table name to use for the filter
    #
    # This method prioritizes the filter's table_name over the scope's table_name.
    # If the filter has a specific table_name configured, it uses that;
    # otherwise, it falls back to the scope's table_name.
    #
    # @return [String] the table name to use for filtering
    #
    # @example With filter table_name specified
    #   filter = Kiroshi::Filter.new(:name, table: 'tags')
    #   runner = FilterRunner.new(filter: filter, scope: Document.joins(:tags), filters: {})
    #   runner.table_name # => 'tags'
    #
    # @example Without filter table_name (fallback to scope)
    #   filter = Kiroshi::Filter.new(:name)
    #   runner = FilterRunner.new(filter: filter, scope: Document.all, filters: {})
    #   runner.table_name # => 'documents'
    #
    # @since 0.1.1
    def table_name
      filter_table_name || scope_table_name
    end

    # @!method scope
    #   @api private
    #
    #   Returns the current scope being filtered
    #
    #   @return [ActiveRecord::Relation] the scope

    private

    attr_reader :filter, :filters

    # @!method filter
    #   @api private
    #   @private
    #
    #   Returns the filter configuration
    #
    #   @return [Kiroshi::Filter] the filter configuration

    # @!method filters
    #   @api private
    #   @private
    #
    #   Returns the hash of filter values
    #
    #   @return [Hash] the hash of filter values

    delegate :attribute, to: :filter
    delegate :table_name, to: :scope, prefix: true
    delegate :table_name, to: :filter, prefix: true

    # @!method attribute
    #   @api private
    #
    #   Returns the attribute name to filter by
    #
    #   @return [Symbol] the attribute name to filter by

    # @!method scope_table_name
    #   @api private
    #
    #   Returns the table name from the scope
    #
    #   @return [String] the table name from the scope

    # @!method filter_table_name
    #   @api private
    #
    #   Returns the table name from the filter configuration
    #
    #   @return [String, nil] the table name from the filter or nil if not specified
  end
end
