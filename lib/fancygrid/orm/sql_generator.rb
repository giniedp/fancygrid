module Fancygrid
  module Orm
    module SqlGenerator#:nodoc:
      
      OPERATOR_NAMES = [
        :equal, :not_equal, :less, :less_equal, :greater, :greater_equal, :starts_with, :ends_with,
        :like, :insensitive_starts_with, :insensitive_ends_with, :insensitive_like,
        :is_null, :is_not_null, :is_true, :is_not_true, :is_false, :is_not_false, :in, :not_in
      ]
      
      attr_accessor :query_options
    
      def initialize(options)

        self.query_options = {}
        
        if grid = options[:grid]
          self.query_options[:order] = grid.view_state.sql_order
        end
        
        if select = options[:select]
          self.query_options[:select] = select
        end
        
        if pagination = options[:pagination]
          self.query_options[:limit] = pagination[:per_page].to_i
          self.query_options[:offset] = (pagination[:page].to_i - 1) * pagination[:per_page].to_i
        end
        
        if conditions = self.build_conditions(options[:operator], options[:conditions])
          self.query_options[:conditions] = conditions
        end
      end
      
      def execute resource_class
        raise "called execute on abstract class"
      end
      
      protected
      
      def build_conditions(operator, search_conditions)
        return nil if Array(search_conditions).empty?
        
        operator = logical_operator(operator)
        conditions = []
        arguments = []
        
        Array(search_conditions).each do |options|
          sql, value = comparison_operator(options[:identifier], options[:operator], options[:value])
          # skip empty LIKE conditions
          next if value == "%%" || value == "%"
          conditions << sql
          arguments << value unless value.nil?
        end
        
        return [conditions.join(operator)] + arguments
      end

      def comparison_operator(column, operator, value)
        operator = case operator.to_s
        when "equal"
          "="
        when "not_equal"
          "!="
        when "less"
          "<"
        when "less_equal"
          "<="
        when "greater"
          ">"
        when "greater_equal"
          ">="
        when "starts_with"
          value = "#{value.to_param}%"
          "LIKE"
        when "ends_with"
          value = "%#{value.to_param}"
          "LIKE"
        when "like"
          value = "%#{value.to_param}%"
          "LIKE"
        when "insensitive_starts_with"
          value = "#{value.to_param}%"
          "ILIKE"
        when "insensitive_ends_with"
          value = "%#{value.to_param}"
          "ILIKE"
        when "insensitive_like"
          value = "%#{value.to_param}%"
          "ILIKE"
        when "is_null"
          value = nil
          "IS NULL"
        when "is_not_null"
          value = nil
          "IS NOT NULL"
        when "is_true"
          value = nil
          "IS TRUE"
        when "is_not_true"
          value = nil
          "IS NOT TRUE"
        when "is_false"
          value = nil
          "IS FALSE"
        when "is_not_false"
          value = nil
          "IS NOT FALSE"
        when "in"
          value = value.split(",")
          "IN"
        when "not_in"
          value = value.split(",")
          "NOT IN"
        else
          "="
        end
        
        if value.nil?
          return "( #{column} #{operator} )", value
        else
          return "( #{column} #{operator} (?) )", value
        end
        
      end
      
      def logical_operator(name)
        case name.to_s
        when "all", "and"
          " AND "
        else
          " OR "
        end
      end
     
       
    end
  end
end