# frozen_string_literal: true

module Kiroshi
  class FilterQuery
    # @api private
    # @author darthjee
    #
    # Query strategy for LIKE matching
    #
    # This class implements the LIKE match query strategy, generating
    # WHERE clauses with SQL LIKE operations for partial matching.
    #
    # @example Applying LIKE match query
    #   query = Kiroshi::FilterQuery::Like.new(filter_runner)
    #   query.apply
    #   # Generates: WHERE table_name.attribute LIKE '%value%'
    #
    # @since 0.1.1
    class Like < FilterQuery
      # Applies LIKE match filtering to the scope
      #
      # This method generates a WHERE clause with SQL LIKE operation
      # for partial matching, including table name prefix to avoid
      # column ambiguity in complex queries.
      #
      # @return [ActiveRecord::Relation] the filtered scope with LIKE match
      #
      # @example Applying LIKE match
      #   query = Like.new(filter_runner)
      #   query.apply
      #   # Generates: WHERE documents.name LIKE '%ruby%'
      #
      # @since 0.1.1
      def apply
        scope.where(
          "#{table_name}.#{attribute} LIKE ?",
          "%#{filter_value}%"
        )
      end
    end
  end
end
