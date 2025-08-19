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
  #   runner = Kiroshi::FilterRunner.new(filter: filter, scope: User.all, value: 'John')
  #   result = runner.apply
  #
  # @example Creating and running a filter with specific value
  #   filter = Kiroshi::Filter.new(:status)
  #   runner = Kiroshi::FilterRunner.new(filter: filter, scope: User.all, value: 'active')
  #   result = runner.apply
  #
  # @since 0.1.0
  class FilterRunner
    # Creates a new FilterRunner instance
    #
    # @param filter [Kiroshi::Filter] the filter configuration
    # @param scope [ActiveRecord::Relation] the scope to filter
    # @param value [Object, nil] the specific value to use for filtering, defaults to nil
    #
    # @since 0.2.0
    def initialize(filter:, scope:, value: nil)
      @filter = filter
      @scope = scope
      @value = value
    end

    # Applies the filter logic to the scope
    #
    # This method contains the actual filtering logic, checking the filter's
    # match type and applying the appropriate WHERE clause to the scope.
    #
    # @return [ActiveRecord::Relation] the filtered scope
    #
    # @example Applying exact match filter
    #   runner = FilterRunner.new(filter: filter, scope: scope, value: 'John')
    #   runner.apply
    #
    # @example Applying LIKE filter
    #   runner = FilterRunner.new(filter: filter, scope: scope, value: 'Ruby')
    #   runner.apply
    #
    # @example With specific value provided
    #   runner = FilterRunner.new(filter: filter, scope: scope, value: 'specific_value')
    #   runner.apply
    #
    # @example With no value (returns unchanged scope)
    #   runner = FilterRunner.new(filter: filter, scope: scope, value: nil)
    #   runner.apply
    #   # Returns the original scope unchanged
    #
    # @since 0.1.1
    def apply
      return scope unless value.present?

      query_strategy = FilterQuery.for(filter.match).new(self)
      query_strategy.apply
    end

    attr_reader :scope, :value

    # @!method scope
    #   @api private
    #
    #   Returns the current scope being filtered
    #
    #   @return [ActiveRecord::Relation] the scope
    #
    #   @since 0.1.1

    # @!method value
    #   @api private
    #
    #   Returns the filter value for the current filter
    #
    #   @return [Object] the filter value or nil if not present
    #
    #   @since 0.2.0

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
    #   runner = FilterRunner.new(filter: filter, scope: Document.joins(:tags), value: 'ruby')
    #   runner.table_name # => 'tags'
    #
    # @example Without filter table_name (fallback to scope)
    #   filter = Kiroshi::Filter.new(:name)
    #   runner = FilterRunner.new(filter: filter, scope: Document.all, value: 'test')
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

    # @!method value
    #   @api private
    #
    #   Returns the filter value for the current filter
    #
    #   @return [Object, nil] the filter value or nil if not present

    private

    attr_reader :filter

    # @!method filter
    #   @api private
    #   @private
    #
    #   Returns the filter configuration
    #
    #   @return [Kiroshi::Filter] the filter configuration

    delegate :column, to: :filter
    delegate :table_name, to: :scope, prefix: true
    delegate :table_name, to: :filter, prefix: true

    # @!method column
    #   @api private
    #
    #   Returns the column name to use in database queries
    #
    #   @return [Symbol] the column name to use in database queries

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
