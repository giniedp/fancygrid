module Railsgrid
  class Column
    attr_accessor :column_type, :column_name, :table
    attr_accessor :model_class, :model_classname, :css_name, :human_name, :table_name, :searchable, :search_value
    
    def initialize column_type, column_name, table      
      unless %(attribute method cell).include? column_type.to_s
        raise "column_type must be one of 'attribute', 'method' or 'cell' but is #{column_type}" 
      end
      # split columnname e.g. "foo[bar][attribute]" => ["foo", "bar", "attribute"]
      column_name_split    = column_name.split(/\[|\]/)
                           
      self.column_type     = column_type.to_sym
      self.column_name     = column_name
      self.css_name        = column_name_split.last
      self.table           = table      
      
      self.model_classname = column_name_split[-2] # ["foo", "bar", "attribute"] => classname is "bar"
      self.model_class     = self.model_classname.camelize.constantize 
      self.searchable      = %(attribute).include? column_type.to_s 
      
      temp = column_name_split.last
      self.human_name   = model_class.human_attribute_name(temp, :default => temp.camelize) 
      self.human_name   = I18n.t("railsgrid.tables.#{column_name_split.join('.')}", :default => human_name)

      self.search_value = ""
      
      if self.model_class < ActiveRecord::Base
        self.table_name = self.model_class.table_name
      else
        self.table_name = self.model_class.name.underscore.pluralize
      end
    end
    
  end
end