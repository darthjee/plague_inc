# frozen_string_literal: true

module Kiroshi
  # @api public
  # Base class for implementing filter sets on ActiveRecord scopes
  #
  # This class provides a foundation for creating reusable filter collections
  # that can be applied to ActiveRecord queries. It uses a class-level DSL
  # to define filters and an instance-level interface to apply them.
  #
  # The class is designed to be inherited by specific filter implementations
  # that define their own set of filters using the {.filter_by} method.
  #
  # @api public
  # @author darthjee
  #
  # @example Basic usage with inheritance
  #   class DocumentFilters < Kiroshi::Filters
  #     filter_by :name, match: :like
  #     filter_by :status
  #     filter_by :created_at, match: :exact
  #   end
  #
  #   filters = DocumentFilters.new(name: 'report', status: 'published')
  #   filtered_documents = filters.apply(Document.all)
  #
  # @example Multiple filter types
  #   class UserFilters < Kiroshi::Filters
  #     filter_by :email, match: :like
  #     filter_by :role
  #     filter_by :active, match: :exact
  #   end
  #
  #   filters = UserFilters.new(email: 'admin', role: 'moderator')
  #   filtered_users = filters.apply(User.all)
  #
  # @since 0.1.0
  class Filters
    class << self
      # Defines a filter for the current filter class
      #
      # This method is used at the class level to configure filters that will
      # be applied when {#apply} is called. Each call creates a new {Filter}
      # instance with the specified configuration.
      #
      # @param attribute [Symbol] the attribute name to filter by
      # @param options [Hash] additional options passed to {Filter#initialize}
      # @option options [Symbol] :match (:exact) the matching type
      #   - +:exact+ for exact matching (default)
      #   - +:like+ for partial matching using SQL LIKE
      #
      # @return [Filter] the new filter instance
      #
      # @example Defining exact match filters
      #   class ProductFilters < Kiroshi::Filters
      #     filter_by :category
      #     filter_by :brand
      #   end
      #
      # @example Defining partial match filters
      #   class SearchFilters < Kiroshi::Filters
      #     filter_by :title, match: :like
      #     filter_by :description, match: :like
      #   end
      #
      # @example Mixed filter types
      #   class OrderFilters < Kiroshi::Filters
      #     filter_by :customer_name, match: :like
      #     filter_by :status, match: :exact
      #     filter_by :payment_method
      #   end
      #
      # @since 0.1.0
      def filter_by(attribute, **)
        Filter.new(attribute, **).tap do |filter|
          filter_configs << filter
        end
      end

      # Returns the list of configured filters for this class
      #
      # @return [Array<Filter>] array of {Filter} instances configured
      #   for this filter class
      #
      # @example Accessing configured filters
      #   class MyFilters < Kiroshi::Filters
      #     filter_by :name
      #     filter_by :status, match: :like
      #   end
      #
      #   MyFilters.filter_configs.length # => 2
      #   MyFilters.filter_configs.first.attribute # => :name
      #
      # @since 0.1.0
      def filter_configs
        @filter_configs ||= []
      end
    end

    # Creates a new Filters instance
    #
    # @param filters [Hash] a hash containing the filter values to be applied.
    #   Keys should correspond to attributes defined with {.filter_by}.
    #   Values will be used for filtering. Nil or blank values are ignored.
    #
    # @example Creating filters with values
    #   filters = DocumentFilters.new(
    #     name: 'annual report',
    #     status: 'published',
    #     category: 'finance'
    #   )
    #
    # @example Creating filters with partial values
    #   filters = UserFilters.new(email: 'admin')  # Only email filter will be applied
    #
    # @example Creating empty filters
    #   filters = ProductFilters.new({})  # No filters will be applied
    #
    # @since 0.1.0
    def initialize(filters = {})
      @filters = filters || {}
    end

    # Applies all configured filters to the given scope
    #
    # This method iterates through all filters defined via {.filter_by}
    # and applies each one sequentially to the scope. Filters with no
    # corresponding value in the filters hash or with blank values are
    # automatically skipped.
    #
    # @param scope [ActiveRecord::Relation] the ActiveRecord scope to filter
    #
    # @return [ActiveRecord::Relation] the filtered scope with all
    #   applicable filters applied
    #
    # @example Applying filters to a scope
    #   class ArticleFilters < Kiroshi::Filters
    #     filter_by :title, match: :like
    #     filter_by :published, match: :exact
    #   end
    #
    #   filters = ArticleFilters.new(title: 'Ruby', published: true)
    #   filtered_articles = filters.apply(Article.all)
    #   # Generates: WHERE title LIKE '%Ruby%' AND published = true
    #
    # @example With empty filters
    #   filters = ArticleFilters.new({})
    #   filtered_articles = filters.apply(Article.all)
    #   # Returns the original scope unchanged
    #
    # @example With partial filters
    #   filters = ArticleFilters.new(title: 'Ruby')  # published filter ignored
    #   filtered_articles = filters.apply(Article.all)
    #   # Generates: WHERE title LIKE '%Ruby%'
    #
    # @since 0.1.0
    def apply(scope)
      self.class.filter_configs.each do |filter|
        scope = filter.apply(scope, filters)
      end

      scope
    end

    private

    attr_reader :filters

    # @!method filters
    #   @api private
    #   @private
    #
    #   Returns the hash of filter values to be applied
    #
    #   @return [Hash] the hash of filter values to be applied
  end
end
