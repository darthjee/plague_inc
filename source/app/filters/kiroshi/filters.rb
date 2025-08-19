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
    autoload :ClassMethods, 'kiroshi/filters/class_methods'

    extend ClassMethods

    # @method self.filter_by(filter_key, **options)
    #   @api public
    #   @param filter_key [Symbol] the filter key name to identify this filter
    #   @param options [Hash] additional options passed to {Filter#initialize}
    #   @option options [Symbol] :match (:exact) the matching type
    #     - +:exact+ for exact matching (default)
    #     - +:like+ for partial matching using SQL LIKE with wildcards
    #   @option options [String, Symbol, nil] :table (nil) the table name to qualify the column
    #     when dealing with joined tables that have conflicting column names
    #   @option options [Symbol, nil] :column (nil) the column name to use in database queries,
    #     defaults to filter_key if not specified
    #
    #   @return [Filter] the new filter instance that was created and registered
    #
    #   @example Defining exact match filters
    #     class ProductFilters < Kiroshi::Filters
    #       filter_by :category      # Exact match on category
    #       filter_by :brand         # Exact match on brand
    #       filter_by :active        # Exact match on active status
    #     end
    #
    #   @example Defining partial match filters
    #     class SearchFilters < Kiroshi::Filters
    #       filter_by :title, match: :like         # Partial match on title
    #       filter_by :description, match: :like   # Partial match on description
    #       filter_by :author_name, match: :like   # Partial match on author name
    #     end
    #
    #   @example Mixed filter types with different matching strategies
    #     class OrderFilters < Kiroshi::Filters
    #       filter_by :customer_name, match: :like  # Partial match for customer search
    #       filter_by :status, match: :exact        # Exact match for order status
    #       filter_by :payment_method               # Exact match (default) for payment
    #     end
    #
    #   @example Filters with table qualification for joined queries
    #     class DocumentTagFilters < Kiroshi::Filters
    #       filter_by :name, table: :documents      # Filter by document name
    #       filter_by :tag_name, table: :tags       # Filter by tag name
    #       filter_by :category, table: :categories # Filter by category name
    #     end
    #
    #   @example Complex real-world filter class
    #     class ProductSearchFilters < Kiroshi::Filters
    #       filter_by :name, match: :like                    # Product name search
    #       filter_by :category_id                           # Exact category match
    #       filter_by :brand, match: :like                   # Brand name search
    #       filter_by :price_min                             # Minimum price
    #       filter_by :price_max                             # Maximum price
    #       filter_by :in_stock                              # Availability filter
    #       filter_by :category_name, table: :categories     # Category name via join
    #     end
    #
    #   @example Using custom column names
    #     class UserFilters < Kiroshi::Filters
    #       filter_by :full_name, column: :name, match: :like    # Filter key 'full_name' maps to 'name' column
    #       filter_by :user_email, column: :email                # Filter key 'user_email' maps to 'email' column
    #       filter_by :account_status, column: :status           # Filter key 'account_status' maps to 'status' column
    #     end
    #
    #   @note When using table qualification, ensure that the specified table
    #     is properly joined in the scope being filtered. The filter will not
    #     automatically add joins - it only qualifies the column name.
    #
    #   @see Filter#initialize for detailed information about filter options
    #   @see Filters#apply for how these filters are used during query execution
    #
    #   @since 0.3.0

    # Creates a new Filters instance
    #
    # @param filters [Hash] a hash containing the filter values to be applied.
    #   Keys should correspond to filter keys defined with {.filter_by}.
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
      @filters = filters
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
    # @since 0.2.0
    def apply(scope)
      filters.compact.each do |filter_key, value|
        filter = self.class.filter_for(filter_key)
        next unless filter

        scope = filter.apply(scope: scope, value: value)
      end

      scope
    end

    private

    # Returns the hash of filter values to be applied
    #
    # Uses lazy initialization to ensure @filters is never nil,
    # defaulting to an empty hash when no filters were provided.
    #
    # @return [Hash] the hash of filter values to be applied
    #
    # @api private
    # @since 0.3.0
    def filters
      @filters ||= {}
    end
  end
end
