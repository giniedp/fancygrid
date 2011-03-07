require "active_support/hash_with_indifferent_access"

module Fancygrid
  class QueryGenerator#:nodoc:
    
    OPERATOR_NAMES = [
      :equal, :not_equal, :less, :less_equal, :greater, :greater_equal, :starts_with, :ends_with, 
      :like, :null, :not_null, :true, :not_true, :false, :not_false, :in, :not_in
    ]
    
    attr_accessor :query

    def initialize(options=nil)
      options ||= {}
      options = ActiveSupport::HashWithIndifferentAccess.new(options)
      
      self.query = {}
      
      self.select(options[:select])
      self.apply_pagination(options[:pagination])
      # TODO:
      self.apply_search_conditions(options[:operator] || :and, options[:conditions])
      self.apply_sort_order(options[:order])
    end
    
    def parse_options(options=nil)#:nodoc:
      options ||= {}
      [:conditions, :order, :group, :having, :limit, :offset, :joins, :include, :select, :from, :readonly, :lock].each do |option|
        self.send(option, options[option]) unless options[option].nil?
      end
    end
    
    # Takes a hash like { :page => 2, :per_page => 20 } and translates it into :limit and :offset options which are
    # then applied to the final query
    #
    def apply_pagination(options=nil)
      options ||= {}
      options = ActiveSupport::HashWithIndifferentAccess.new(options)
      self.limit(options[:per_page].to_i)
      self.offset(options[:page].to_i * self.limit())
    end
    
    # Takes a hash like { :column => "users.name", :order => "asc" } and translates it into the :order option and
    # then applies it to the final query
    #
    def apply_sort_order(options=nil)
      self.order("#{options[:column]} #{options[:order].to_s.upcase}") if options
    end
    
    # Takes an operator and an conditions hash like { :<table> => { :<column> => [{ :oparator => <op>, :value => <value> }] } }
    # and converts them into a query joined by the given operator
    #
    def apply_search_conditions(operator, search_conditions)
      return unless search_conditions
      
      operator = logical_operator(operator)
      
      conditions = []
      arguments = []
      
      # backward compatibility
      search_conditions = search_conditions.map do |table, columns|
        columns.map do |column, value|
          if value.is_a?(Hash)
            if value.keys.all? { |key| key.to_s.match(/^\d+$/) }
              # for hashes like this
              # :<table> => { 
              #   :<column> => {
              #     "0" => { :oparator => <op>, :value => <value> },
              #     "1" => { :oparator => <op>, :value => <value> },
              #     "2" => { :oparator => <op>, :value => <value> }
              #   } 
              # }
              #
              value.map{ |key, opts|
                { :column => "#{table}.#{column}", :operator => opts[:operator], :value => opts[:value] } 
              }
            else
              # for hashes like this
              # :<table> => { 
              #   :<column> => {
              #     :oparator => <op>, :value => <value>
              #   } 
              # }
              #
              { :column => "#{table}.#{column}", :operator => value[:operator], :value => value[:value] } 
            end
          elsif value.is_a?(Array)
              # for hashes like this
              # :<table> => { 
              #   :<column> => {
              #     [{ :oparator => <op>, :value => <value> },
              #      { :oparator => <op>, :value => <value> },
              #      { :oparator => <op>, :value => <value> }]
              #   } 
              # }
              #
            value.map{ |opts|
              { :column => "#{table}.#{column}", :operator => opts[:operator], :value => opts[:value] } 
            }
          else
              # for hashes like this
              # :<table> => { 
              #   :<column> => <value>
              # }
              #
            unless value.blank?
              { :column => "#{table}.#{column}", :operator => :like, :value => value } 
            else 
              nil
            end
          end
        end
      end
      search_conditions = search_conditions.flatten
      
      search_conditions.each do |options|
        next unless options
        sql_query, value = comparison_operator(options[:column], options[:operator], options[:value])
        conditions << sql_query
        arguments << value if (value)
      end
      
      conditions = [conditions.join(operator)] + arguments
      append_conditions(:and, conditions)
    end
    
    # Joins two conditions arrays or strings with the given operator
    #
    # === Example
    #
    #    condition1 = ["first_name = ?", first_name]
    #    condition2 = ["last_name = ?", last_name]
    #
    #    join_conditions(:and, condition1, condition2)
    #    # => ["(first_name = ?) AND (last_name = ?)", first_name, last_name]
    #
    def join_conditions(operator, conditions1, conditions2)
      conditions1 = Array(conditions1)
      conditions2 = Array(conditions2)
      operator = logical_operator(operator).gsub(" ", "")
      
      if conditions1.empty?
        return [] if conditions2.empty?
        return conditions2
      elsif conditions2.empty?
        return conditions1
      end
      
      left_sql = conditions1.shift
      right_sql = conditions2.shift
      
      if left_sql.blank?
        return [] if right_sql.blank?
        return [right_sql] + conditions2
      elsif right_sql.blank?
        return [left_sql] + conditions1
      end
      
      conditions = "(#{left_sql}) #{operator} (#{right_sql})"
      return [conditions] + conditions1 + conditions2
    end
    
    def append_conditions(operator, conditions)
      self.query[:conditions] = join_conditions(operator, self.query[:conditions], conditions)
    end
    
    # An SQL fragment like “administrator = 1”, ["user_name = ?", username], or ["user_name = :user_name", { :user_name => user_name }]
    #
    def conditions(conditions=nil)
      if conditions
        append_conditions(:and, conditions)
      end
      self.query[:conditions]
    end
    
    # An SQL fragment like “created_at DESC, name”. 
    #
    def order(order_by=nil)
      self.query[:order] = order_by if order_by
      self.query[:order]
    end
    
    # An SQL fragment like “created_at DESC, name”.
    #
    def group(group_by=nil)
      self.query[:group] = group_by if group_by
      self.query[:group]
    end
    
    # An attribute name by which the result should be grouped. Uses the GROUP BY SQL-clause.
    #
    def having(having_sql=nil)
      self.query[:having] = having_sql if having_sql
      self.query[:having]
    end
    
    # An integer determining the limit on the number of rows that should be returned.
    #
    def limit(num=nil)
      self.query[:limit] = num if num
      self.query[:limit]
    end
    
    # An integer determining the offset from where the rows should be fetched. So at 5, it would skip rows 0 through 4.
    #
    def offset(num=nil)
      self.query[:offset] = num if num
      self.query[:offset]
    end
    
    # Either an SQL fragment for additional joins like “LEFT JOIN comments ON comments.post_id = id” (rarely needed), 
    # named associations in the same form used for the :include option, which will perform an INNER JOIN on the 
    # associated table(s), or an array containing a mixture of both strings and named associations. If the value is a 
    # string, then the records will be returned read-only since they will have attributes that do not correspond to the 
    # table’s columns. Pass :readonly => false to override.
    #
    def joins(to_join_with=nil)
      self.query[:joins] = to_join_with if to_join_with
      self.query[:joins]      
    end
    
    # Names associations that should be loaded alongside. The symbols named refer to already defined associations. 
    # See eager loading under Associations.
    #
    def include(to_include=nil)
      self.query[:include] = to_include if to_include
      self.query[:include]
    end
    
    # By default, this is “*” as in “SELECT * FROM”, but can be changed if you, for example, want to do a join but not 
    # include the joined columns. Takes a string with the SELECT SQL fragment (e.g. “id, name”).
    #
    def select(select = nil)
      if select
        self.query[:select] = Array(self.query[:select])
        self.query[:select] |= Array(select)
        
        if self.query[:select].include?("*")
          self.query[:select] = ["*"]
        end
      end
      self.query[:select]
    end
    
    # By default, this is the table name of the class, but can be changed to an alternate table name 
    # (or even the name of a database view).
    #
    def from(table_name=nil)
      self.query[:from] = table_name if table_name
      self.query[:from]
    end
    
    # Mark the returned records read-only so they cannot be saved or updated.
    #
    def readonly(value=nil)
      self.query[:readonly] = value unless value.nil?
      self.query[:readonly]
    end
    
    # An SQL fragment like “FOR UPDATE” or “LOCK IN SHARE MODE”. :lock => true gives connection’s default exclusive 
    # lock, usually “FOR UPDATE”.
    #
    def lock(value=nil)
      self.query[:lock] = value unless value.nil?
      self.query[:lock]
    end
    
    private
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
      when "null"
        value = nil
        "IS NULL"
      when "not_null"
        value = nil
        "IS NOT NULL"
      when "true"
        value = nil
        "IS TRUE"
      when "not_true"
        value = nil
        "IS NOT TRUE"
      when "false"
        value = nil
        "IS FALSE"
      when "not_false"
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