module Fancygrid

  class Grid < Fancygrid::Node
    
    cattr_accessor :table_template
    cattr_accessor :list_template
    cattr_accessor :control_template
    cattr_accessor :cells_template
    
    attr_accessor :url
    attr_accessor :leafs
    attr_accessor :query
    attr_accessor :toolbars
    attr_accessor :request_params
    attr_accessor :dataset
    attr_accessor :pagecount
    attr_accessor :custom_cells_template
    attr_accessor :search_enabled
    
    # may be one of 'table' or 'list'
    attr_accessor :grid_type
    
    def initialize(name, klass = nil, table_name = nil, params = nil)
      super(self, nil, name)
      initialize_node(name, klass, table_name)
      
      self.url            = nil
      self.leafs          = []
      self.dataset        = nil
      self.pagecount      = 0
      self.toolbars       = {}
      self.query          = {}
      self.request_params = (params || {})
      self.custom_cells_template = nil
      self.grid_type      = Fancygrid.default_grid_type.to_s
      self.search_enabled = Fancygrid.search_enabled
    end
    
    def is_static?
      self.url.blank?
    end
    
    def button toolbar_name, button_name, button_value
      # Buttons are currently not supported
    end
    
    def find options = nil
      raise "calling 'find' twice or after 'data=' is not allowed" unless dataset.nil?
      
      # use given user options in first place. we override them 
      # later with the fancygrid options
      self.query = options || {}

      # find all select keys and add to query
      unless self.leafs.empty?
        self.query[:select] ||= []
        if self.query[:select] != "*"
          self.query[:select] = self.query[:select].to_a
          self.query[:select] += self.leafs.map{ |leaf| leaf.select_name }.compact
        end
      end
      
      # extract parameters that are designed for this grid
      params = request_params.delete("fancygrid") || {}
      params = params.delete(self.name) || {}
      
      # build pagination conditions
      if params[:pagination]
        self.query[:limit] = params[:pagination][:per_page].to_i
        self.query[:offset] = params[:pagination][:page].to_i * self.query[:limit].to_i
      end
      
      # build order conditions
      unless params[:order].blank?
        self.query[:order] = params[:order] 
      end
      

      # build search conditions
      if params[:conditions]
        params_conditions = array_to_hash(hash_to_array(params[:conditions]).flatten)
        params_conditions.reject!{ |k, v| v.blank? }
        
        cond_string = params_conditions.map{ |k, v| "#{k} LIKE ?" }.join(" AND ")
        cond_args = []
        params_conditions.each{ |k, v| cond_args << "%#{v.to_param}%" }
        
        # merge custom conditions with search conditions
        if self.query[:conditions]
          raise ":conditions option expected to be an array" unless self.query[:conditions].is_a? Array
          
          str = self.query[:conditions].shift
          str = "(#{str})"
          str << " AND (#{cond_string})" unless cond_string.blank?
          
          arg = self.query[:conditions]
          arg += cond_args
          
          
          cond_string = str
          cond_args = arg
        end
        
        self.query[:conditions] = ([cond_string] + cond_args)
      end 
      
      query_for_data unless params.empty?
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

    def each_leaf
      leafs.each do |leaf|
        yield leaf if leaf.visible
      end
    end
    
    def data= data
      self.dataset = data.to_a
      self.pagecount = 1
      self.url = nil
    end
    
    def query_for_data
      if self.record_klass < ActiveRecord::Base
        self.dataset = self.record_klass.find(:all, self.query)
        
        count_query = self.query.reject do |k, v| 
          [:limit, :offset, :order].include? k 
        end
        self.pagecount  = self.record_klass.count(:all, count_query)
        
      elsif self.record_klass < ActiveResource::Base
        self.dataset = self.record_klass.find(:all, :params => self.query)
        self.pagecount = self.dataset.delete_at(self.dataset.length - 1).total
      end
      
      if self.pagecount.respond_to?(:length)
        self.pagecount  = self.pagecount.length 
      end
    end
    
    def save
      self
    end
    
    def template= name
      if name
        self.custom_cells_template = Rails.root.join("app", "views", "fancygrid", "_#{name}.html.haml")
      else
        self.custom_cells_template = nil
      end
    end
    
    def js_options
      {
        :url => self.url,
        :name => self.name,
        :isStatic => self.is_static?,
        :gridType => self.grid_type,
        :searchEnabled => self.search_enabled
      }.to_json
    end
  end
end