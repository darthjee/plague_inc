# frozen_string_literal: true

module Kiroshi
  class FilterQuery
    # @api private
    # @author darthjee
    #
    # Query strategy for exact matching
    #
    # This class implements the exact match query strategy, generating
    # WHERE clauses with exact equality comparisons.
    #
    # @example Applying exact match query
    #   query = Kiroshi::FilterQuery::Exact.new(filter_runner)
    #   query.apply
    #   # Generates: WHERE attribute = 'value'
    #
    # @since 0.1.1
    class Exact < FilterQuery
      # Applies exact match filtering to the scope
      #
      # This method generates a WHERE clause with exact equality matching
      # for the filter's attribute and value.
      #
      # @return [ActiveRecord::Relation] the filtered scope with exact match
      #
      # @example Applying exact match
      #   query = Exact.new(filter_runner)
      #   query.apply
      #   # Generates: WHERE status = 'published'
      #
      # @since 0.1.1
      def apply
        scope.where(table_name => { attribute => value })
      end
    end
  end
end
