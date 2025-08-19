# frozen_string_literal: true

module Kiroshi
  # @api private
  # @author darthjee
  #
  # Factory class for creating filter query strategies
  #
  # This class implements the Strategy pattern for handling different types of
  # database queries based on the filter match type. It provides a factory method
  # to create the appropriate query strategy class.
  #
  # @example Getting an exact match query strategy
  #   query = Kiroshi::FilterQuery.for(:exact).new(filter_runner)
  #   query.apply
  #
  # @example Getting a LIKE match query strategy
  #   query = Kiroshi::FilterQuery.for(:like).new(filter_runner)
  #   query.apply
  #
  # @since 0.1.1
  class FilterQuery
    autoload :Exact, 'kiroshi/filter_query/exact'
    autoload :Like, 'kiroshi/filter_query/like'

    class << self
      # Factory method to create the appropriate query strategy
      #
      # This method returns the correct query strategy class based on the
      # match type provided. It serves as the main entry point for creating
      # query strategies.
      #
      # @param match [Symbol] the type of matching to perform
      #   - :exact for exact matching
      #   - :like for partial matching using SQL LIKE
      #
      # @return [Class] the appropriate FilterQuery subclass
      #
      # @example Creating an exact match query
      #   query_class = Kiroshi::FilterQuery.for(:exact)
      #   # Returns Kiroshi::FilterQuery::Exact
      #
      # @example Creating a LIKE match query
      #   query_class = Kiroshi::FilterQuery.for(:like)
      #   # Returns Kiroshi::FilterQuery::Like
      #
      # @raise [ArgumentError] when an unsupported match type is provided
      #
      # @since 0.1.1
      def for(match)
        case match
        when :exact
          Exact
        when :like
          Like
        else
          raise ArgumentError, "Unsupported match type: #{match}"
        end
      end
    end

    # Creates a new FilterQuery instance
    #
    # @param filter_runner [Kiroshi::FilterRunner] the filter runner instance
    #
    # @since 0.1.1
    def initialize(filter_runner)
      @filter_runner = filter_runner
    end

    # Base implementation for applying a filter query
    #
    # This method should be overridden by subclasses to provide specific
    # query logic for each match type.
    #
    # @return [ActiveRecord::Relation] the filtered scope
    #
    # @raise [NotImplementedError] when called on the base class
    #
    # @since 0.1.1
    def apply
      raise NotImplementedError, 'Subclasses must implement #apply method'
    end

    private

    attr_reader :filter_runner

    # @!method filter_runner
    #   @api private
    #   @private
    #
    #   Returns the filter runner instance
    #
    #   @return [Kiroshi::FilterRunner] the filter runner instance

    delegate :scope, :attribute, :table_name, :value, to: :filter_runner

    # @!method scope
    #   @api private
    #
    #   Returns the current scope being filtered
    #
    #   @return [ActiveRecord::Relation] the scope

    # @!method attribute
    #   @api private
    #
    #   Returns the attribute name to filter by
    #
    #   @return [Symbol] the attribute name

    # @!method table_name
    #   @api private
    #
    #   Returns the table name for the filter
    #
    #   @return [String] the table name

    # @!method value
    #   @api private
    #
    #   Returns the filter value
    #
    #   @return [Object] the filter value
  end
end
