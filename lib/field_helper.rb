module Fancygrid

  module FieldHelper
    
    attr_accessor :name
    attr_accessor :fancygrid_instance
    attr_accessor :record_name
    attr_accessor :record_path
    attr_accessor :record_class
    attr_accessor :record_table
    
    def columns_for(call_name, record_class = nil, options = nil, &block)
      raise ArgumentError, "Missing block" unless block_given?
      
      dummy = Fancygrid::Field.new()
      dummy.fancygrid_instance = self.fancygrid_instance
      grid_setup(dummy, call_name, record_class, options)
      dummy.record_path = [self.record_path, call_name].compact.join(".")
      read_options(dummy, options)
      
      yield dummy
    end
    
    def column(field_name, options = {})
      fancygrid_instance.cells << cell = Fancygrid::Field.new()
      
      cell.fancygrid_instance = self.fancygrid_instance
      cell.record_name  = self.record_name
      cell.record_path  = self.record_path
      cell.record_class = self.record_class
      cell.record_table = self.record_table
      cell.field_name   = field_name.to_s
      cell.name         = field_name
      cell.search_value = ""
      
      read_options(cell, options)
    end
    
    def columns(names, options)
      names.flatten.each do |name|
        column(name, options)
      end
    end
    
    def attributes(*names)
      options = names.extract_options!
      options[:searchable] = true if options[:searchable].blank?
      columns(names, options)
    end
    
    def methods(*names)
      options = names.extract_options!
      options[:searchable] = false
      columns(names, options)
    end
    
    def rendered(*names)
      options = names.extract_options!
      options[:searchable] = false
      options[:formatable] = true
      columns(names, options)
    end
    
    def hidden(*names)
      options = names.extract_options!
      options[:searchable] = true
      options[:formatable] = false
      options[:hidden]     = true
      columns(names, options)
    end
    
    def tag_name
      "#{self.record_table}[#{self.name}]"
    end
    
    def i18n_path
      [:fancygrid, :tables, self.fancygrid_instance.name, self.record_path, self.field_name].compact.join(".")
    end
    
    private
    def grid_setup(cell, call_name, record_class = nil, options = {})
      
      cell.name = call_name
      
      if record_class.is_a? Class 
        cell.record_class = record_class 
        cell.record_name  = cell.record_class.name.underscore
      else
        cell.record_class = call_name.to_s.classify.constantize
        cell.record_name  = cell.record_class.name.underscore
      end
      
      if cell.record_class.respond_to?(:table_name)
        cell.record_table = cell.record_class.table_name
      else
        cell.record_table = cell.record_class.name.tableize
      end
    end
    
    def read_options cell, options = nil
      raise ArgumentError, "cell must not be nil" if cell.nil?
      
      options ||= {}
      cell.record_name  = (options[:record_name]  or cell.record_name ) 
      cell.record_path  = (options[:record_path]  or cell.record_path )
      cell.record_class = (options[:record_class] or cell.record_class)
      cell.record_table = (options[:record_table] or cell.record_table)
      
      cell.searchable   = (options[:searchable] && !options[:formatable] or false)
      cell.formatable   = (options[:formatable] or false)
      cell.human_name   = (options[:human_name] or cell.field_name.to_s.humanize)
      cell.hidden       = (options[:hidden] or false)
      
      unless options[:human_name]
        if cell.record_class.respond_to?(:human_attribute_name)
          cell.human_name = cell.record_class.human_attribute_name(cell.field_name, :default => cell.human_name)
        end
        cell.human_name = I18n.t(cell.i18n_path, :default => cell.human_name)
      end
      
    end
    
    def combine_record_path(a, b)
      [a.record_path, b.record_path].compact.join(".")
    end
    
  end  
end