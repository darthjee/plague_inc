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
    #   # Generates: WHERE "table_name"."column" LIKE '%value%'
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
      #   # Generates: WHERE "documents"."name" LIKE '%ruby%'
      #
      # @since 0.1.1
      def apply
        scope.where(sql_query, "%#{value}%")
      end

      private

      # @api private
      # @private
      #
      # Builds the SQL query string for LIKE matching
      #
      # This method constructs the SQL fragment with proper table and column
      # qualification using double quotes to avoid conflicts with reserved words.
      #
      # @return [String] the SQL query fragment for LIKE matching
      #
      # @example Generated SQL fragment
      #   sql_query # => '    # Constructs the parameterized SQL query string for column matching
      #
      # @return [String] The SQL query string with placeholders
      # @example
      #   sql_query
      #   # Returns: '"table_name"."column" LIKE ?''
      #
      # @since 0.3.0
      def sql_query
        <<~SQL.squish
          "#{table_name}"."#{column}" LIKE ?
        SQL
      end
    end
  end
end
