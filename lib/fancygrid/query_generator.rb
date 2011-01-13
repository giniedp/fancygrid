module Fancygrid
  class QueryGenerator#:nodoc:
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
        
    def select(select = nil)
      select = Array(select) | Array(self.defaults[:select])
      select.include?("*") ? "*" : select
    end
    
    def joins
      self.defaults[:joins]
    end
    
    def where(conditions_hash = {})
      conditions_hash ||= {}

      conditions = []
      values = []

      conditions_hash.each_pair do |k,v|
        v.reject!{ |sk, sv| sv.blank? }
        v.each_pair do |sk, sv|
          substring = "#{k}.#{sk}"
          if sv.is_a?(Hash)
            # new hash conditions
            condition = resolve_operator(substring, sv[:value], sv[:operator]) #["a = ?", "value"]
          else
            # old compatibility
            condition = ["#{substring} LIKE ?", "%#{sv}%"]
          end
          conditions << condition.first
          values << condition.last
        end
      end
      
      cond_string = conditions.join(boolean_operator)
      cond_args = values
      
      # merging options with params conditions
      if self.defaults[:conditions]
        raise ":conditions option expected to be an array" unless self.defaults[:conditions].is_a? Array
        defaults = self.defaults[:conditions]
                
        str = defaults.shift
        str = "(#{str})"
        str << " AND (#{cond_string})" unless cond_string.blank?
        
        arg = defaults
        arg += cond_args
        
        
        cond_string = str
        cond_args = arg
      end

      ([cond_string] + cond_args)
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
        :joins => joins,
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
      when "starts_with"
        condition = "#{key} LIKE ?"
        value = "#{value}%"
      when "ends_with"
        condition = "#{key} LIKE ?"
        value = "%#{value}"
      when "is_like"
        condition = "#{key} LIKE ?"
        value = "%#{value}%"
      when "is_greater_than"
        condition = "#{key} > ?"
      when "is_lower_than"
        condition = "#{key} < ?"
      else
        condition = "#{key} = ?"
      end
      [condition, value]
    end
    
    def boolean_operator
      @query[:all] == "1" ? " AND " : " OR "
    end
    
    def hash_to_array k, v=nil
      if k.is_a? Hash
        k.map{ |k2, v2| hash_to_array(k2, v2) }
      elsif v.is_a? Hash
        v.map{ |k2, v2| hash_to_array("#{k}.#{k2}", v2) }
      else
        [k, v]
      end
    end
    
    def array_to_hash(array)
      count = 0
      hash = Hash.new
      (array.length / 2).times do
        hash[array[count]] = array[count+1]
        count += 2
      end
      return hash
    end
  end
end