# frozen_string_literal: true

module Kiroshi
  # @author darthjee
  #
  # A filter class that applies filtering logic to ActiveRecord scopes
  #
  # This class provides a flexible way to apply filters to database queries,
  # supporting both exact matches and partial matches using SQL LIKE operations.
  #
  # @example Creating and applying an exact filter
  #   filter = Kiroshi::Filter.new(:name)
  #   filtered_scope = filter.apply(Document.all, { name: 'John' })
  #
  # @example Creating and applying a LIKE filter
  #   filter = Kiroshi::Filter.new(:title, match: :like)
  #   filtered_scope = filter.apply(Article.all, { title: 'Ruby' })
  #
  # @since 0.1.0
  class Filter
    # Creates a new Filter instance
    #
    # @param attribute [Symbol] the attribute name to filter by
    # @param match [Symbol] the matching type, defaults to :exact
    # @option match [Symbol] :exact performs exact matching (default)
    # @option match [Symbol] :like performs partial matching using SQL LIKE
    #
    # @example Creating an exact match filter
    #   filter = Kiroshi::Filter.new(:status)
    #
    # @example Creating a partial match filter
    #   filter = Kiroshi::Filter.new(:name, match: :like)
    #
    # @since 0.1.0
    def initialize(attribute, match: :exact)
      @attribute = attribute
      @match = match
    end

    # Applies the filter to the given scope
    #
    # This method examines the filters hash for a value corresponding to the
    # filter's attribute and applies the appropriate WHERE clause to the scope.
    # If no value is present or the value is blank, the original scope is returned unchanged.
    #
    # @param scope [ActiveRecord::Relation] the ActiveRecord scope to filter
    # @param filters [Hash] a hash containing filter values
    #
    # @return [ActiveRecord::Relation] the filtered scope
    #
    # @example Applying an exact filter
    #   filter = Kiroshi::Filter.new(:status)
    #   filter.apply(Document.all, { status: 'published' })
    #   # Generates: WHERE status = 'published'
    #
    # @example Applying a LIKE filter
    #   filter = Kiroshi::Filter.new(:title, match: :like)
    #   filter.apply(Article.all, { title: 'Ruby' })
    #   # Generates: WHERE title LIKE '%Ruby%'
    #
    # @example With empty filter value
    #   filter = Kiroshi::Filter.new(:name)
    #   filter.apply(User.all, { name: nil })
    #   # Returns the original scope unchanged
    #
    # @since 0.1.0
    def apply(scope, filters)
      filter_value = filters[attribute]
      return scope unless filter_value.present?

      case match
      when :like
        scope.where("#{attribute} LIKE ?", "%#{filter_value}%")
      else # :exact (default)
        scope.where(attribute => filter_value)
      end
    end

    private

    attr_reader :attribute, :match

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
