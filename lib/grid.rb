module Fancygrid

  class Grid
    include Fancygrid::FieldHelper
    
    cattr_accessor :frame_template
    cattr_accessor :control_template
    cattr_accessor :cells_template
    
    attr_accessor :url
    attr_accessor :cells
    attr_accessor :query
    attr_accessor :result
    attr_accessor :toolbars
    attr_accessor :request_params
    
    def initialize(call_name, record_class = nil, request_params={})
      
      self.url      = "/"
      self.cells    = []
      self.result   = nil
      self.toolbars = {}
      self.query    = {}
      self.request_params = request_params
      self.fancygrid_instance = self
      
      grid_setup(self, call_name, record_class)
    end
    
    # grid does not need a record path
    def record_path= value
    end
    
    # grid does not need a record path
    def record_path
      nil
    end
    
    def button toolbar_name, button_name, button_value
      # TODO
      #self.toolbars[toolbar_name] ||= Fancygrid::Toolbar.new(toolbar_name)
      #self.toolbars[toolbar_name].button(button_name, button_value)
    end
    
    def find options = nil

      # use given user options in first place. we override them 
      # later with the fancygrid options
      self.query = options || {}

      # find all select keys and add to query
      unless self.query[:select]
        self.query[:select] = self.cells.map{ |cell| cell.finder_select_name }.compact
        self.query[:select] = "*" if self.query[:select].empty?
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
        
        conditions = []
        conditions << params_conditions.map{ |k, v| "#{k} LIKE ?" }.join(" AND ")
        params_conditions.each{ |k, v| conditions << "%#{v.to_param}%" }
        self.query[:conditions] = conditions
      end 
      
      unless params.empty?
        self.result ||= Fancygrid::Result.new(self)
      end
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

    def each_cell
      cells.each do |cell|
        next if cell.hidden
        yield cell
      end
    end
    
    def values_for record
      values = []
      self.each_cell do |cell|
        
        value  = ""
        reflection_path = cell.record_path.to_s.split(/\./)
        reflection_path << cell.field_name
        
        evaluated = record
        while reflection_path.length > 0
          token = reflection_path.shift
          next if token.blank?
          next if evaluated.nil?
          next unless evaluated.respond_to?(token)
          evaluated = evaluated.send(token)
          value = evaluated
        end
        
        if cell.formatable && block_given?
          value = yield cell, value
        end
        
        values << value
      end
      
      values
    end
    
    def save
      self
    end
  end
end