module Fancygrid#:nodoc:

  #{
  #  :columns => [
  #    { :identifier => <string>, :visible => <bool>, :position => <number> }
  #  ]
  #  :conditions => [
  #    { :identifier => <string>, :operator => <string>, :value => <string> }
  #  ], 
  #  :operator => ["all"|"any"],
  #  :order => { :identifier => <string>, :direction => ["asc"|"desc"|""] },
  #  :pagination => { :page => <number>, :per_page => <number> }
  #}  
  class ViewState
    
    attr_accessor :dump
      
    def initialize(dump = {})
      raise ArgumentError, "'dump' must be a Hash" unless dump.is_a? Hash
      self.dump = dump.with_indifferent_access
      self.fix_columns
      self.fix_conditions
      self.fix_order
      self.fix_pagination
      
      Rails.logger.debug self.dump.inspect
    end
    
    def column_options(node)
      self.dump[:columns].select { |hash| 
        node.identifier == hash[:identifier] 
      }.first || {}
    end
    
    def column_option(node, option, default)
      self.column_options(node).fetch(option, default)
    end
    
    def column_conditions(node)
      self.dump[:conditions].select { |hash| 
        node.identifier == hash[:identifier] 
      }.first || {}
    end
    
    def column_condition(node, option, default)
      self.column_conditions(node).fetch(option.to_s, default)
    end

    def conditions
      self.dump[:conditions]
    end
        
    def operator
      self.dump[:operator]
    end
    
    def conditions_match_all?
      self.dump.fetch(:conditions_match, :any).to_s == "all"
    end
    
    def order
      self.dump.fetch(:order, {})
    end
    
    def order_table
      self.order[:identifier].to_s.split(".").first
    end
    
    def order_column
      self.order[:identifier].to_s.split(".").last
    end

    def order_direction
      self.order[:direction]
    end

    def column_order(node)
      if node.identifier.to_s == self.order[:identifier].to_s
        self.order_direction
      end
    end
    
    def ordered?
      !(order_table.blank? || order_column.blank? || order_direction.blank?)
    end
    
    def sql_order
      return nil unless ordered?
      return "#{order_table}.#{order_column} #{order_direction}"
    end
    
    def pagination
      self.dump.fetch(:pagination, {})
    end

    def pagination_page default=1
      result = self.pagination.fetch(:page, default)
      return default if result <= 0
      return result
    end

    def pagination_per_page default=20
      result = self.pagination.fetch(:per_page, default)
      return default if result <= 0
      return result
    end
    
    def pagination_options(default_page, default_per_page)
      {
        :page => self.pagination_page(default_page).to_i,
        :per_page => self.pagination_per_page(default_per_page).to_i
      }
    end
    
    def search_visible
      self.dump.fetch(:search_visible, false)
    end

    protected
    # converts the columns option into an array of hashes 
    # 
    def fix_columns
      h = self.dump
      # conditions may be passed as a hash like { "0" => {}, "1" => {}}
      h[:columns] = h[:columns].values if h[:columns].is_a? Hash
      # ensure that columns is an array
      h[:columns] = [] unless h[:columns].is_a? Array
      # filter out invalid entries.
      h[:columns] = h[:columns].select { |entry| entry.is_a?(Hash) }
    end
    
    # converts the conditions options in to an array of hashes 
    # with at least an :identifier and :operator
    #
    #    { :identifier => <string>, :operator => [all|any] }
    def fix_conditions
      h = self.dump

      # conditions may be passed as a hash like { "0" => {}, "1" => {}}
      h[:conditions] = h[:conditions].values if h[:conditions].is_a? Hash
      # ensure that conditions is an array
      h[:conditions] = [] unless h[:conditions].is_a? Array
      # filter out invalid entries.
      h[:conditions] = h[:conditions].select { |entry| entry.is_a?(Hash) && entry[:identifier].present? && entry[:operator].present? }
      h[:operator] = "all" unless %w(all any).include? h[:operator]
    end
    
    def fix_order
      self.dump[:order] = {} unless self.dump[:order].is_a? Hash
      hash = self.dump[:order]
      hash.delete(:identifier)unless hash[:identifier].is_a? String
      hash.delete(:direction) unless %w(asc desc).include? hash[:direction]
    end
    
    def fix_pagination
      self.dump[:pagination] = {} unless self.dump[:pagination].is_a? Hash
      hash = self.dump[:pagination]
      hash[:page]     = hash[:page].to_i     if hash.has_key? :page
      hash[:per_page] = hash[:per_page].to_i if hash.has_key? :per_page
    end

  end
end
