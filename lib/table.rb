module Fancygrid
  class Table
    cattr_accessor :frame_template, :control_template, :cells_template
    attr_accessor :name, :model_classname, :model_class, :table_name, :url
    attr_accessor :columns, :query, :result, :toolbars
    
    #
    #
    #
    def initialize resource, klass=null
      
      self.name     = resource
      self.url      = "/"
      self.columns  = []
      self.result   = nil
      self.toolbars = {}
      self.query    = {}
      
      if klass.is_a? Class 
        self.model_class      = klass 
        self.model_classname  = klass.name.underscore
      else
        self.model_class      = resource.to_param.singularize.camelize.constantize
        self.model_classname  = self.model_class.name.underscore
      end
      
      if self.model_class < ActiveRecord::Base
        self.table_name       = self.model_class.table_name
      else
        self.table_name       = self.model_classname.camelize.demodulize.underscore.pluralize
      end
    
    end
    
    def fields field_type, model_name, names
      names = [names] unless names.is_a? Array
      names.each do |name|
        self.columns << Fancygrid::Column.new(name, field_type, "#{model_name}[#{name}]", self)
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
      #self.toolbars[toolbar_name] ||= Fancygrid::Toolbar.new(toolbar_name)
      #self.toolbars[toolbar_name].button(button_name, button_value)
    end
    
    def build_query params={}
      if params[:pagination]
        self.query[:limit] = params[:pagination][:per_page].to_i
        self.query[:offset] = params[:pagination][:page].to_i * self.query[:limit].to_i
      end
      
      unless params[:order].blank?
        self.query[:order] = params[:order] 
      end
      
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
        self.result = Fancygrid::Result.new(self)
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
          while attribute.length > 0
            if attribute[0].blank? || !instance.respond_to?(attribute[0])
              attribute.shift
            else
              value = instance.send(attribute.shift)
              instance = value
            end
          end
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