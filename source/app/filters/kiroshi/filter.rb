# frozen_string_literal: true

module Kiroshi
  # @api private
  # @author darthjee
  #
  # A filter class that applies filtering logic to ActiveRecord scopes
  #
  # This class provides a flexible way to apply filters to database queries,
  # supporting both exact matches and partial matches using SQL LIKE operations.
  #
  # @example Creating and applying an exact filter
  #   filter = Kiroshi::Filter.new(:name)
  #   filtered_scope = filter.apply(scope: Document.all, value: 'John')
  #
  # @example Creating and applying a LIKE filter
  #   filter = Kiroshi::Filter.new(:title, match: :like)
  #   filtered_scope = filter.apply(scope: Article.all, value: 'Ruby')
  #
  # @example Creating and applying a filter with specific value
  #   filter = Kiroshi::Filter.new(:status)
  #   filtered_scope = filter.apply(scope: Document.all, value: 'published')
  #
  # @since 0.1.0
  class Filter
    attr_reader :attribute, :match, :table_name

    # @!method attribute
    #   @api private
    #
    #   Returns the attribute name to filter by
    #
    #   @return [Symbol] the attribute name to filter by

    # @!method match
    #   @api private
    #
    #   Returns the matching type (+:exact+ or +:like+)
    #
    #   @return [Symbol] the matching type (+:exact+ or +:like+)

    # @!method table_name
    #   @api private
    #
    #   Returns the table name to qualify the attribute
    #
    #   @return [String, String, nil] the table name or nil if not specified

    # Creates a new Filter instance
    #
    # @param attribute [Symbol] the attribute name to filter by
    # @param match [Symbol] the matching type, defaults to :exact
    # @param table [String, Symbol, nil] the table name to qualify the attribute, defaults to nil
    # @option match [Symbol] :exact performs exact matching (default)
    # @option match [Symbol] :like performs partial matching using SQL LIKE
    #
    # @example Creating an exact match filter
    #   filter = Kiroshi::Filter.new(:status)
    #
    # @example Creating a partial match filter
    #   filter = Kiroshi::Filter.new(:name, match: :like)
    #
    # @example Creating a filter with table qualification
    #   filter = Kiroshi::Filter.new(:name, table: 'documents')
    #
    # @since 0.1.0
    def initialize(attribute, match: :exact, table: nil)
      @attribute = attribute
      @match = match
      @table_name = table
    end

    # Applies the filter to the given scope
    #
    # This method applies the appropriate WHERE clause to the scope using the
    # provided value. If no value is present or the value is blank, the original
    # scope is returned unchanged.
    #
    # @param scope [ActiveRecord::Relation] the ActiveRecord scope to filter
    # @param value [Object, nil] the value to use for filtering, defaults to nil
    #
    # @return [ActiveRecord::Relation] the filtered scope
    #
    # @example Applying an exact filter
    #   filter = Kiroshi::Filter.new(:status)
    #   filter.apply(scope: Document.all, value: 'published')
    #   # Generates: WHERE status = 'published'
    #
    # @example Applying a LIKE filter
    #   filter = Kiroshi::Filter.new(:title, match: :like)
    #   filter.apply(scope: Article.all, value: 'Ruby')
    #   # Generates: WHERE title LIKE '%Ruby%'
    #
    # @example Applying a filter with table qualification
    #   filter = Kiroshi::Filter.new(:name, table: 'documents')
    #   filter.apply(scope: Document.joins(:tags), value: 'report')
    #   # Generates: WHERE documents.name = 'report'
    #
    # @example Applying a filter with table qualification for tags
    #   filter = Kiroshi::Filter.new(:name, table: 'tags')
    #   filter.apply(scope: Document.joins(:tags), value: 'ruby')
    #   # Generates: WHERE tags.name = 'ruby'
    #
    # @example With empty filter value
    #   filter = Kiroshi::Filter.new(:name)
    #   filter.apply(scope: User.all, value: nil)
    #   # Returns the original scope unchanged
    #
    # @since 0.2.0
    def apply(scope:, value: nil)
      runner = FilterRunner.new(filter: self, scope: scope, value: value)
      runner.apply
    end
  end
end
