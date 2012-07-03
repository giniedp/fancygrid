module Fancygrid
  
  class Node

    # The fancygrid root node.
    attr_reader :root

    # The paent node.
    attr_reader :parent
    
    # Array of child nodes.
    attr_reader :children
            
    # The name of this node.
    attr_reader :name
    
    # The corresponding resource class.
    attr_reader :resource_class

    # The table name of the resource class.
    attr_reader :table_name

    # Initializes the node.
    #
    def initialize(parent, name, options = {})
      raise ArgumentError, "expected parent to be a Node" if !parent.nil? && !parent.is_a?(Fancygrid::Node)
      raise ArgumentError, "name must not be blank" if name.blank?
      
      @parent   = parent
      @name     = name.to_s
      @children = []
      @root     = self.get_root
      
      @resource_class = options.fetch(:class) do 
        self.name.to_s.classify.constantize 
      end
      
      @table_name = options.fetch(:table_name) do
        if self.resource_class.respond_to?(:table_name)
          self.resource_class.table_name
        else
          self.resource_class.name.tableize
        end
      end
      
      self.parent.add_child self if self.parent.present?
    end
    
    # Creates and yields a child node.
    #
    def columns_for(name, options = {})# :yields:
      node = Fancygrid::Node.new(self, name, options)
      yield node if block_given?
      return node
    end
    
    # Creates and adds a column to this node.
    #
    def column(name, options = {})
      options[:class] ||= self.resource_class
      options[:table_name] ||= self.table_name
      Fancygrid::Column.new(self, name, options)
    end
    
    # Creates and adds a column for each given parameter.
    # The columns are marked to be not selectable and not searchable.
    #
    def columns(*names)
      options = names.extract_options!
      options[:searchable] = options.fetch(:searchable, false)
      options[:selectable] = options.fetch(:selectable, false)
      options[:value_proc] = Proc.new if block_given?
      names.flatten.map { |name| self.column(name, options) }
    end
    
    # Creates and adds a column for each given parameter.
    # The columns are marked as selectable and searchable.
    #
    def attributes(*names)
      options = names.extract_options!
      options[:searchable] = options.fetch(:searchable, true)
      options[:selectable] = options.fetch(:selectable, true)
      columns(names, options)
    end
    
    # Gets a dot separated string of names of all parent nodes including own.
    #
    def name_chain
      if @name_chain.nil?
        prefix = (parent and parent.name_chain)
        @name_chain = [prefix, self.name].compact.join(".")
      end
      return @name_chain
    end
  
    # Returns true if this node is the root node of the tree.
    #
    def root?
      self.root.equal?(self)
    end
    
    # Collects all columns into the given collection 
    #
    def collect_columns collection
      self.children.each do |child|
        child.collect_columns collection
      end
      return collection
    end
        
    protected
    
    # Adds a child to this node.
    #
    def add_child(node)
      raise ArgumentError, "node must be a Fancygrid::Node" unless node.is_a? Fancygrid::Node
      raise ArgumentError, "node must not be a root node" if node.root?
      raise ArgumentError, "node with name #{node.name} has been already inserted" if self.children.any? { |child| child.name == node.name }
      self.children << node
    end

    # Gets the root node of this tree
    #
    def get_root
      self.parent.nil? ? self : self.parent.get_root
    end
  end  
end