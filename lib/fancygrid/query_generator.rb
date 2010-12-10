module Fancygrid
  class QueryGenerator
    attr_accessor :query

    attr_accessor :defaults
        
    # This should be instanciated from Grid so we should receive:
    # :conditions => {
    #   :model => {:conditions}
    # },
    # :order => {...},
    # :select => {},
    # :joins => ...
    def initialize(defaults = {})
      self.defaults = defaults
    end
        
    def override(options)
      self.options = options
    end

    def select(select = nil)
      select = Array(select) || []
      # select = self.defaults[:select] || []
      # unless @leafs.empty?
      #   if select != "*"
      #     select = select.to_a
      #     select += @leafs.map{ |leaf| leaf.select_name }.compact
      #   end
      # end
      # select
      select |= Array(self.defaults[:select]) || []
      select.include?("*") ? "*" : select
    end
    
    def where(conditions_hash = {})
      conditions_hash ||= {}

      conditions = []
      values = []

      conditions_hash.each_pair do |k,v|
        v.each_pair do |sk, sv|
          substring = "#{k}.#{sk}"
          condition = resolve_operator(substring, sv[:value], sv[:operator]) #["a = ?", "value"]
          conditions << condition.first
          values << condition.last
        end
      end
      
      # we have to concatenate this with defaults[:conditions] (AND)
      conditions = values.unshift(conditions.join(boolean_operator))
    end
    
    def offset(pagination = nil)
      pagination ? pagination[:page].to_i * self.limit(pagination) : 0
    end
    
    def limit(pagination = nil)
      pagination ? pagination[:per_page].to_i : 0
    end

    def order(order = nil)
      order || self.defaults[:order]
    end

    def evaluate(query = {})
      self.query = query
      {
        :conditions => where(query[:conditions]),
        :offset => offset(query[:pagination]),
        :limit => limit(query[:pagination]),
        :order => order(query[:order]),
        :select => select(query[:select])
      }
    end

    private
    def resolve_operator(key, value, operator)
      case operator
      when "is_equal_to"
        condition = "#{key} = ?"
      else
        condition = "#{key} = ?"
      end
      [condition, value]
    end
    
    def boolean_operator
      @query[:all] == "1" ? " AND " : " OR "
    end
  end
end