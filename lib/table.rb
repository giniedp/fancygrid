module Railsgrid
  class Table
    cattr_accessor :frame_template, :control_template, :cells_template
    attr_accessor :model_classname, :model_class, :css_selector, :url
    attr_accessor :columns, :query, :result, :toolbars
    
    def initialize model_classname
      self.model_classname = model_classname.to_s
      self.model_class     = model_classname.to_s.camelize.constantize
      self.css_selector    = model_classname.to_s.gsub(/\//, "_") # cant have slashes in css selector
      self.url             = "/" + model_classname.to_s.pluralize
      self.columns         = []
      self.result          = nil
      self.toolbars        = {}
      self.query = {
        :joins      =>  nil, 
        :limit      =>  nil, 
        :readonly   =>  false, 
        :select     =>  nil, 
        :group      =>  nil, 
        :offset     =>  nil, 
        :include    =>  nil, 
        :conditions =>  nil
      }
    end
    
    def name
      self.model_classname
    end
    
    def fields field_type, model_name, names
      names = [names] unless names.is_a? Array
      names.each do |name|
        self.columns << Railsgrid::Column.new(field_type, "#{model_name}[#{name}]", self)
      end
    end
    
    def attributes names, model_name=nil
      self.fields(:attribute, (model_name or self.model_classname), names)
    end
    
    def methods names, model_name=nil
      self.fields(:method, (model_name or self.model_classname), names)
    end
    
    def cells names, model_name=nil
      self.fields(:cell, (model_name or self.model_classname), names)
    end
    
    def button toolbar_name, button_name, button_value
      # TODO
      #self.toolbars[toolbar_name] ||= Railsgrid::Toolbar.new(toolbar_name)
      #self.toolbars[toolbar_name].button(button_name, button_value)
    end
    
    def build_query params
      if params[:pagination]
        self.query[:limit] = params[:pagination][:per_page].to_i
        self.query[:offset] = params[:pagination][:page].to_i * self.query[:limit].to_i
      end
      
      self.query[:order] = params[:order] if params[:order]
      
      if params[:conditions]
        params_conditions = {}
        flatten_conditions(params[:conditions], params_conditions)
        params_conditions.reject!{ |k, v| v.blank? }
        
        conditions = []
        conditions << params_conditions.map{ |k, v| "#{k} LIKE ?" }.join(" AND ")
        params_conditions.each{ |k, v| conditions << "%#{v.to_param}%" }
        self.query[:conditions] = conditions
      end
      return self.query
    end
    
    def flatten_conditions hash, flat
      hash.each do |k, v|
        if v.is_a? Hash
          flatten_conditions(v, flat)
        else
          flat[k] = v
        end
      end
    end
    
    def run_query params
      unless self.result
        self.build_query(params)
        self.result = Railsgrid::Result.new(self)
      end
      self.result
    end
    
    def values item, params
      run_query(params)
      
      values = []
      self.columns.each do |col|
        attribute = col.column_name.split(/\[|\]/)
        attribute.shift # first is always the model name, skip it
        
        value = ""
        if col.column_type == :cell
          if block_given?
            value = yield item, col
          end
        else
          instance = item
          (value = instance.send(attribute.shift)) and (instance = value) while attribute.length > 0
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