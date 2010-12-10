module Fancygrid
  class QueryGenerator
    attr_accessor :query
    attr_accessor :leafs
    
    attr_accessor :options
        
    # This should be instanciated from Grid so we should receive:
    # :conditions => {
    #   :model => {:conditions}
    # },
    # :order => {...},
    # :pagination => {}
    def initialize(query, leafs = nil)
      @query = query
      @leafs = leafs
      self.options = {}
    end
        
    def override(options)
      self.options = options
    end

    def select
      select = self.options[:select] || []
      unless @leafs.empty?
        if select != "*"
          select = select.to_a
          select += @leafs.map{ |leaf| leaf.select_name }.compact
        end
      end
      select
    end
    
    def where
      conditions = []
      values = []
      
      @query[:conditions].each_pair do |k,v|
        v.each_pair do |sk, sv|
          substring = "#{k}.#{sk}"
          condition = resolve_operator(substring, sv[:value], sv[:operator]) #["a = ?", "value"]
          conditions << condition.first
          values << condition.last
        end
      end
      
      # we have to concatenate this with options[:conditions] (AND)
      conditions = values.unshift(conditions.join(boolean_operator))
    end
    
    def offset
      @query[:pagination][:page].to_i * self.limit
    end
    
    def limit
      @query[:pagination][:per_page].to_i
    end
    
    def pagination?
      @query[:pagination].present?
    end
    
    def order
      self.options[:order] || @query[:order]
    end
    
    def order?
      order.present?
    end
    
    def evaluate
      {:conditions => where, :offset => offset, :limit => limit, :order => order}
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