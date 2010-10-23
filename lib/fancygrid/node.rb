module Fancygrid
  
  I18N_PREFIX = "fancygrid.tables"
  
  class Node
    
    # Top level node. Must be a Fancygrid::Grid instance
    attr_accessor :root
    
    # Parent node. Can be a Fancygrid::Grid or Fancygrid::Node instance
    attr_accessor :parent
    
    # Collection of Fancygrid::Node's that define fields of this node
    attr_accessor :children
    
    
    
    # User defined name of this field or table
    attr_accessor :name
    
    # Class constant of the model holding this field
    attr_accessor :record_klass
    
    # Table name of the model holding this field
    attr_accessor :record_table_name
    
    
    
    # Human name of this field
    attr_accessor :human_name
    
    # Specifies whether this field is searchable or not
    attr_accessor :searchable
    
    # Specifies whether this field is formatable or not
    attr_accessor :formatable
    
    # Specifies the last value of this field
    attr_accessor :search_value
    
    # Specifies whether this field is rendered or not
    attr_accessor :visible
    
    
    
    def initialize(root, parent, name)
      self.root         = root
      self.parent       = parent
      self.name         = name
      self.children     = nil
    end
    
    
    
    def columns_for(name, klass = nil, table_name = nil, options = nil, &block)
      raise ArgumentError, "Missing block" unless block_given?
      node = Fancygrid::Node.new(self.root, self, name)
      node.initialize_node(name, klass, table_name, options)
      
      self.children ||= []
      self.children << node
      
      yield node
    end
    
    def column(name, options = nil)
      node = Fancygrid::Node.new(self.root, self, name)
      node.initialize_node(name, self.record_klass, self.record_table_name)
      node.initialize_leaf(options)
      
      self.children ||= []
      self.children << node
      root.leafs    << node
    end
    
    def columns(names, options)
      names.flatten.each do |name|
        column(name, options)
      end
    end
    
    
    
    def attributes(*names)
      options = names.extract_options!
      options[:searchable] = true  if options[:searchable].nil?
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = true  if options[:visible].nil?
      columns(names, options)
    end
    
    def methods(*names)
      options = names.extract_options!
      options[:searchable] = false
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = true  if options[:visible].nil?
      columns(names, options)
    end
    
    def rendered(*names)
      options = names.extract_options!
      options[:searchable] = false
      options[:formatable] = true
      options[:visible]    = true  if options[:visible].nil?
      columns(names, options)
    end
    
    def hidden(*names)
      options = names.extract_options!
      options[:searchable] = true
      options[:formatable] = false
      options[:visible]    = false
      columns(names, options)
    end
    
    
    
    def is_leaf?
      self.children.nil?
    end
    
    def tag_name
      is_leaf? and "#{self.record_table_name}[#{self.name}]" or self.name.to_s
    end
    
    def select_name
      searchable and "#{self.record_table_name}.#{self.name}"
    end
    
    def css_class
      "#{self.record_table_name} #{self.name}"
    end
    
    def i18n_path
      prefix = ((parent and parent.i18n_path) or Fancygrid::I18N_PREFIX)
      "#{prefix}.#{self.name}"
    end
    
    def trace
      prefix = (parent and parent.trace)
      [prefix, self.name].compact.join(".")
    end
    
    def find_human_name
      default = self.name.to_s.humanize
      if self.record_klass.respond_to?(:human_attribute_name)
        default = self.record_klass.human_attribute_name(self.name, :default => default)
      end
      I18n.t(self.i18n_path, :default => default)
    end
    
    
    def value_from record
      value  = ""
      reflection_path = self.trace.split(/\./)
      reflection_path.shift # first is always the roots name, dont need this
      
      evaluated = record
      while reflection_path.length > 0
        token = reflection_path.shift
        next if token.blank?
        next if evaluated.nil?
        next unless evaluated.respond_to?(token)
        evaluated = evaluated.send(token)
        value = evaluated
      end
      
      return value
    end
    
    protected    
    def initialize_node(name, klass = nil, table_name = nil, options = nil)
      self.name = name
      if klass.is_a? Class 
        self.record_klass = klass
      else
        self.record_klass = self.name.to_s.classify.constantize
      end
      if table_name
        self.record_table_name = table_name
      elsif self.record_klass.respond_to?(:table_name)
        self.record_table_name = self.record_klass.table_name
      else
        self.record_table_name = self.record_klass.name.tableize
      end
    end
    
    def initialize_leaf options = nil
      options ||= {}

      self.searchable   = options[:searchable] && !options[:formatable]
      self.formatable   = options[:formatable]
      self.visible      = options[:visible]
      
      self.human_name   = (options[:human_name] or self.name.to_s.humanize)
      self.human_name   = find_human_name unless options[:human_name]
    end
    
  end  
end