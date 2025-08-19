# frozen_string_literal: true

module Kiroshi
  class Filters
    # @api public
    # Class-level methods for configuring filters in Kiroshi::Filters
    #
    # This module provides the DSL methods that allow filter classes to
    # define their filtering behavior using class-level method calls.
    # These methods are automatically available when extending Kiroshi::Filters.
    #
    # The primary interface is the {.filter_by} method, which registers
    # filters that will be applied when {Filters#apply} is called on
    # instances of the filter class.
    #
    # @example Basic filter configuration
    #   class DocumentFilters < Kiroshi::Filters
    #     filter_by :name, match: :like
    #     filter_by :status
    #     filter_by :category, table: :documents
    #   end
    #
    # @example Accessing filter configurations
    #   DocumentFilters.filter_configs.keys # => ["name", "status", "category"]
    #   DocumentFilters.filter_configs["name"].match # => :like
    #
    # @since 0.2.0
    # @author darthjee
    module ClassMethods
      # Defines a filter for the current filter class
      #
      # This method is used at the class level to configure filters that will
      # be applied when {Filters#apply} is called. Each call creates a new {Filter}
      # instance with the specified configuration and stores it in the class's
      # filter registry for later use during filtering operations.
      #
      # The method supports various matching strategies and table qualification
      # options to handle complex database queries with joins and ambiguous
      # column names.
      #
      # @overload filter_by(filter_key, **options)
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
      # @return (see Filters.filter_by)
      # @example (see Filters.filter_by)
      # @note (see Filters.filter_by)
      # @see (see Filters.filter_by)
      # @since (see Filters.filter_by)
      def filter_by(filter_key, **options)
        Filter.new(filter_key, **options).tap do |filter|
          filter_configs[filter_key.to_s] = filter
        end
      end

      # @api private
      # Returns the filter configuration for a specific filter key
      #
      # This method provides a convenient way to retrieve a specific filter
      # by its filter key name. It's a shorthand for accessing the filter_configs
      # hash directly and is used internally by the filtering system.
      #
      # @param filter_key [Symbol, String] the filter key name to look up
      #
      # @return [Filter, nil] the filter instance for the given filter key,
      #   or nil if no filter is configured for that filter key
      #
      # @example Retrieving a specific filter
      #   class MyFilters < Kiroshi::Filters
      #     filter_by :name, match: :like
      #     filter_by :status
      #   end
      #
      #   MyFilters.filter_for(:name)    # => #<Kiroshi::Filter:0x... @filter_key=:name @match=:like>
      #   MyFilters.filter_for(:status)  # => #<Kiroshi::Filter:0x... @filter_key=:status @match=:exact>
      #   MyFilters.filter_for(:unknown) # => nil
      #
      # @see .filter_configs for accessing the complete filter registry
      # @see Filters#apply for how this method is used during filtering
      #
      # @since 0.3.0
      def filter_for(filter_key)
        filter_key_string = filter_key.to_s
        filter_configs[filter_key_string] || inherited_filter_for(filter_key_string)
      end

      private

      # @api private
      # @private
      #
      # Searches for a filter in the inheritance chain
      #
      # This method looks up the inheritance chain to find a filter configuration
      # for the given filter key. It only searches in superclasses that inherit
      # from Kiroshi::Filters, stopping when it reaches a non-Filters class.
      #
      # @param filter_key_string [String] the filter key name to look up
      # @return [Filter, nil] the filter instance from a parent class, or nil if not found
      #
      # @since 0.3.0
      def inherited_filter_for(filter_key_string)
        return nil unless superclass < Kiroshi::Filters

        superclass.filter_for(filter_key_string)
      end

      # @api private
      # @private
      #
      # Returns the hash of configured filters for this filter class
      #
      # This method provides access to the internal registry of filters
      # that have been configured using {.filter_by}. The returned hash
      # contains {Filter} instances keyed by their filter key names, allowing
      # for efficient O(1) lookup during filter application.
      #
      # This method is primarily used internally by {Filters#apply} to
      # iterate through and apply all configured filters to a scope.
      # While marked as private API, it may be useful for introspection
      # and testing purposes.
      #
      # @return [Hash<String, Filter>] hash of {Filter} instances configured
      #   for this filter class, keyed by filter key name for efficient access
      #
      # @example Accessing configured filters for introspection
      #   class MyFilters < Kiroshi::Filters
      #     filter_by :name, match: :like
      #     filter_by :status
      #     filter_by :category, table: :categories
      #   end
      #
      #   MyFilters.filter_configs.length                    # => 3
      #   MyFilters.filter_configs.keys                      # => ["name", "status", "category"]
      #   MyFilters.filter_configs["name"].attribute         # => :name
      #   MyFilters.filter_configs["name"].match             # => :like
      #   MyFilters.filter_configs["status"].match           # => :exact
      #   MyFilters.filter_configs["category"].table_name    # => :categories
      #
      # @example Using in tests to verify filter configuration
      #   RSpec.describe ProductFilters do
      #     it 'configures the expected filters' do
      #       expect(described_class.filter_configs).to have_key("name")
      #       expect(described_class.filter_configs["name"].match).to eq(:like)
      #     end
      #   end
      #
      # @note This method returns a reference to the actual internal hash.
      #   Modifying the returned hash directly will affect the filter class
      #   configuration. Use {.filter_by} for proper filter registration.
      #
      # @note The hash is lazily initialized on first access and persists
      #   for the lifetime of the class. Each filter class maintains its
      #   own separate filter_configs hash.
      #
      # @see .filter_by for adding filters to this configuration
      # @see Filters#apply for how these configurations are used
      #
      # @since 0.2.0
      def filter_configs
        @filter_configs ||= {}
      end
    end
  end
end
