
module Fancygrid#:nodoc:
  
  class Node

    # Top level node. Must be a Fancygrid::Grid instance
    attr_accessor :root
    
    # Parent node. Can be a Fancygrid::Grid or Fancygrid::Node instance or <tt>nil</tt>
    attr_accessor :parent
    
    # Collection of Fancygrid::Node's that define fields or nested resources of 
    # this node
    attr_accessor :children
    
        
    # User defined name of this field or table
    attr_accessor :name
    
    # Class constant of the model that is represented by this node
    attr_accessor :record_klass
    
    # Table name of the model that is represented by this node
    attr_accessor :record_table_name

    
    # Specifies the column position from left to right in the final table
    attr_accessor :position
    
    # Specifies the search value of this column
    attr_accessor :search_value
    
    # Specifies whether this column is searchable or not
    attr_accessor :searchable
    
    # Specifies whether this column is formatted with a custom rendering code
    attr_accessor :formatable
    
    # Specifies whether this column is rendered or not
    attr_accessor :visible
    
    # Specifies whether this column refers to a database field and has a selector
    attr_accessor :selectable
    
    # Specifies the custom block to use on a record to resolve a value for rendering
    attr_accessor :proc_block
    

    def initialize(root, parent, name)
      raise "root element must be an instance of Fancygrid::Grid" unless root.is_a?(Fancygrid::Grid)
      self.root         = root
      self.parent       = parent
      self.name         = name
      self.children     = nil
    end
    
    
    # Creates a child node with given <tt>name</tt>, <tt>klass</tt> and <tt>table_name</tt>.
    # See +initialize_node+ method for more information
    def columns_for(name, klass = nil, table_name = nil, options = nil, &block)
      raise ArgumentError, "Missing block" unless block_given?
      node = Fancygrid::Node.new(self.root, self, name)
      node.initialize_node(name, klass, table_name, options)
      
      self.children ||= []
      self.children << node
      
      yield node
    end
    
    # Creates a child leaf for this node. A leaf represents a column in the final table.
    # === options
    # * <tt>:visible</tt> _TrueClass_ value specifying whether the column is rendered to the final table or not
    # * <tt>:searchable</tt> _TrueClass_ value specifying whether the column has a search field in the final table or not
    # * <tt>:formatable</tt> _TrueClass_ value specifying whether the column is formatted with custom rendering code or not
    # * <tt>:selectable</tt> _TrueClass_ value specifying whether the column is a database field and has a selector
    # * <tt>:proc</tt> _Proc_ block that should be run to retrieve a value from a record
    def column(name, options = nil)
      node = Fancygrid::Node.new(self.root, self, name)
      node.initialize_node(name, self.record_klass, self.record_table_name)
      node.initialize_leaf(options)
      
      self.children ||= []
      self.children << node
      root.insert_node(node)
      #root.leafs    << node
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> array with the passed <tt>options</tt>.
    def columns(names, options)
      names.flatten.each do |name|
        column(name, options)
      end
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> argument
    # Sets the following <tt>options</tt> if not already set in the <tt>options</tt> argument
    # * <tt>:searchable => true</tt>
    # * <tt>:formatable => false</tt>
    # * <tt>:visible => true</tt>
    # * <tt>:selectable => true</tt>
    # === Example
    #     
    #     node.attributes(:status)
    #
    #     # is a shortcut for
    #
    #     node.column(:status, {
    #       :searchable => true,
    #       :formatable => false,
    #       :visible => true,
    #       :selectable => true,
    #     })
    def attributes(*names)
      options = names.extract_options!
      options[:searchable] = true  if options[:searchable].nil?
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = true  if options[:visible].nil?
      options[:selectable] = true  if options[:selectable].nil?
      columns(names, options)
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> argument.
    # Sets the following <tt>options</tt> if not already set in the <tt>options</tt> argument
    # * <tt>:searchable => false</tt>
    # * <tt>:formatable => false</tt>
    # * <tt>:visible => true</tt>
    # * <tt>:selectable => false</tt>
    # === Example
    #     
    #     node.methods(:status)
    #
    #     # is a shortcut for
    #
    #     node.column(:status, {
    #       :searchable => false,
    #       :formatable => false,
    #       :visible => true,
    #       :selectable => false,
    #     })
    def methods(*names)
      options = names.extract_options!
      options[:searchable] = false if options[:searchable].nil?
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = true  if options[:visible].nil?
      options[:selectable] = options[:selectable].nil? ? options[:searchable] : options[:selectable]
      columns(names, options)
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> argument.
    # Sets the following <tt>options</tt> if not already set in the <tt>options</tt> argument
    # * <tt>:searchable => false</tt>
    # * <tt>:formatable => true</tt>
    # * <tt>:visible => true</tt>
    # * <tt>:selectable => false</tt>
    # === Example
    #     
    #     node.rendered(:status)
    #
    #     # is a shortcut for
    #
    #     node.column(:status, {
    #       :searchable => false,
    #       :formatable => true,
    #       :visible => true,
    #       :selectable => false,
    #     })
    def rendered(*names)
      options = names.extract_options!
      options[:searchable] = false if options[:searchable].nil?
      options[:formatable] = true  if options[:formatable].nil?
      options[:visible]    = true  if options[:visible].nil?
      options[:selectable] = options[:selectable].nil? ? options[:searchable] : options[:selectable]
      columns(names, options)
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> argument.
    # Sets the following <tt>options</tt> if not already set in the <tt>options</tt> argument
    # * <tt>:searchable => true</tt>
    # * <tt>:formatable => false</tt>
    # * <tt>:visible => false</tt>
    # * <tt>:selectable => true</tt>
    # === Example
    #     
    #     node.hidden(:status)
    #
    #     # is a shortcut for
    #
    #     node.column(:status, {
    #       :searchable => true,
    #       :formatable => false,
    #       :visible => false,
    #       :selectable => true,
    #     })
    def hidden(*names)
      options = names.extract_options!
      options[:searchable] = true  if options[:searchable].nil?
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = false if options[:visible].nil?
      options[:selectable] = true  if options[:selectable].nil?
      columns(names, options)
    end
    
    # Creates a <tt>column</tt> for each value in the <tt>names</tt> argument.
    # Sets the following <tt>options</tt> if not already set in the <tt>options</tt> argument
    # * <tt>:searchable => false</tt>
    # * <tt>:formatable => false</tt>
    # * <tt>:visible => true</tt>
    # * <tt>:selectable => false</tt>
    # * <tt>:proc => proc</tt>
    # === Example
    #     
    #     node.proc(:status) do |record|
    #       record.status
    #     end
    #
    #     # is a shortcut for
    #
    #     node.column(:status, {
    #       :searchable => false,
    #       :formatable => false,
    #       :visible => true,
    #       :selectable => false,
    #       :proc => Proc.new { |record| record.status }
    #     })
    def proc(name, options=nil)
      raise "Missing block" unless block_given?
      options ||= {}
      options[:searchable] = false  if options[:searchable].nil?
      options[:formatable] = false if options[:formatable].nil?
      options[:visible]    = true if options[:visible].nil?
      options[:selectable] = options[:selectable].nil? ? options[:searchable] : options[:selectable]
      options[:proc]       = Proc.new
      column(name, options)
    end
    
    # Gets a value indicating whether this node is a leaf or not.
    # === Example
    #     
    #     grid = Fancygrid::Grid.new(:ticket) # is_leaf? => false
    #     grid.column(:column)                # is_leaf? => true
    #     grid.attributes(:title)             # is_leaf? => true
    #     grid.methods(:status)               # is_leaf? => true
    #     grid.rendered(:foo)                 # is_leaf? => true
    #     grid.hidden(:bar)                   # is_leaf? => true
    #     
    #     grid.columns_for(:project) do |p|   # is_leaf? => false
    #       p.attributes(:description)        # is_leaf? => true
    #     end
    def is_leaf?
      self.children.nil?
    end
    
    # Returns the <tt>tag_name</tt> of this node if it is a leaf. Otherwise returns <tt>nil</tt>.
    # === Example
    #     
    #     grid = Fancygrid::Grid.new(:ticket) # tag_name => nil
    #     grid.attributes(:title)             # tag_name => "tickets[title]"
    #     grid.attributes(:status)            # tag_name => "tickets[status]"
    #     
    #     grid.columns_for(:project) do |p|   # tag_name => nil
    #       p.attributes(:description)        # tag_name => "projects[description]"
    #     end
    def tag_name
      if is_leaf? && @tag_name.nil?
        @tag_name = "#{self.record_table_name}[#{self.name}]"
      end
      @tag_name
    end
    
    # Returns the database select name of this node if it is a leaf and is selectable. 
    # Otherwise returns <tt>nil</tt>. The <tt>select_name</tt> is used in the 
    # finder <tt>:select</tt> option to select fields from database.
    # === Example
    #     
    #     grid = Fancygrid::Grid.new(:ticket) # select_name => nil
    #     grid.attributes(:title)             # select_name => "tickets.title"
    #     grid.attributes(:status)            # select_name => "tickets.status"
    #     grid.methods(:foo)                  # select_name => nil
    #     
    #     grid.columns_for(:project) do |p|   # select_name => nil
    #       p.attributes(:description)        # select_name => "projects.description"
    #     end
    def select_name
      if is_leaf? && selectable && @select_name.nil?
        @select_name = "#{self.record_table_name}.#{self.name}"
      end
      @select_name
    end
    
    # Returns the css selector of this node if it is a leaf. Otherwise returns 
    # <tt>nil</tt>. The <tt>css_class</tt> is there to identify a column in the rendered output
    # and consist of the <tt>record_table_name</tt> and the leafs +name+
    # === Example
    #     
    #     grid = Fancygrid::Grid.new(:ticket) # css_class => nil
    #     grid.attributes(:title)             # css_class => "tickets title"
    #     grid.attributes(:status)            # css_class => "tickets status"
    #     
    #     grid.columns_for(:project) do |p|   # css_class => nil
    #       p.attributes(:description)        # css_class => "projects description"
    #     end
    def css_class
      if is_leaf? && @css_class.nil?
        @css_class = []
        @css_class << self.record_table_name
        @css_class << self.name
        @css_class << "js-orderable" if self.searchable
      end
      @css_class
    end
    
    def applied_sort_order
      return "" unless root.view
      
      # get the sort order from the view. it may look like this: "table.column ASC"
      sort_order = root.view.get_sort_order.to_s
      sort_order = sort_order.gsub(self.select_name.to_s, "").gsub(" ", "")
      if %w(ASC DESC).include?(sort_order)
        sort_order
      else
        ""
      end
    end
    
    def search_input_kind
      return @search_input_kind if @search_input_kind
      
      @search_input_kind = :none
      root.search_formats.each do |key, values|
        next unless values.is_a? Hash
        @search_input_kind = key if values.keys.include?(self.select_name)
      end
      
      @search_input_kind
    end
    
    def search_input_options
      return @search_input_options if @search_input_options
      
      @search_input_options = {}
      
      root.search_formats.each do |key, values|
        next unless values.is_a? Hash
        opts = values[self.select_name.to_s] 
        @search_input_options = opts if opts.is_a?(Hash)
      end
      
      @search_input_options
    end
    
    def search_select_collection
      return @search_select_collection if @search_select_collection
      
      opts = search_input_options
      
      collection = opts[:collection] || []
      text_method = opts[:text_method] || "id"
      value_method = opts[:value_method] || "to_s"

      collection = collection.map do |item|
        [item.send(text_method), item.send(value_method)]
      end
      
      if opts[:prompt]
        collection.insert(0, [opts[:prompt], ""])
      else
        collection.insert(0, ["", ""])
      end
      
      
      @search_select_collection = collection
    end
    
    # Returns the internationalization path for this node if it is a leaf.
    # Otherwise returns nil. The <tt>i18n_path</tt> is used to lookup the <tt>human_name</tt>
    # of this node and is the <tt>trace_path</tt> preceded with the value from 
    # <tt>Fancygrid.i18n_scope</tt>
    def i18n_path
      if is_leaf? && @i18n_path.nil?
        @i18n_path = "#{Fancygrid.i18n_scope}.tables.#{self.trace_path}"
      end
      @i18n_path
    end
    
    # Returns the trace path of this node. A trace path is the path from the
    # root node to this node including all names joined with a dot <tt>.</tt>
    # === Example
    #     
    #     grid = Fancygrid::Grid.new(:ticket)
    #     grid.columns_for(:project) do |p|
    #       p.trace_path # => "ticket.project"
    #     end
    #     grid.trace_path # => "ticket"
    
    def trace_path
      unless @trace_path
        prefix = (parent and parent.trace_path)
        @trace_path = [prefix, self.name].compact.join(".")
      end
      @trace_path
    end
    
    # Sets the human name on this node
    def human_name= value
      @human_name = value
    end
    
    # Returns a human name of this node if it is a leaf. Otherwie returns <tt>nil</tt>.
    def human_name
      if is_leaf? && @human_name.nil?
        default = self.name.to_s.humanize
        if self.record_klass.respond_to?(:human_attribute_name)
          default = self.record_klass.human_attribute_name(self.name, :default => default)
        end
        @human_name = I18n.t(self.i18n_path, :default => default)
      end
      @human_name
    end
    
    # Gets a value from given <tt>record</tt> using the nodes <tt>trace_path</tt>. 
    # === Example
    #     
    #     # having a node with the following trace path
    #     node # trace_path => "ticket.project.description"
    #
    #     # and a ticket model with an assigned project
    #     ticket = new Ticket(project)
    #
    #     # then the following are the same
    #     node.value_from(ticket) 
    #     ticket.project.description
    #
    # ---
    # If the node has a proc, then the trace path is ignored
    # === Example
    #
    #     # having a node with the following trace path
    #     node # trace_path => "ticket.project.description"
    #     # and we assign a proc to the node
    #     node.proc_block = Proc.new { |record| record.project.description }
    #
    #     # and a ticket model with an assigned project
    #     ticket = new Ticket(project)
    #
    #     # then the following are the same
    #     node.value_from(ticket) 
    #     ticket.proc_block.call(ticket)
    #     ticket.project.description
    def value_from record
      root.log("Resolve '#{self.trace_path}' from '#{record}' (#{record.to_param})")
      
      if self.proc_block
        return proc_block.call(record)
      end
      
      # default result value is an empty string
      value  = ""
      
      # create an array from the nodes trace path and shift the first name away
      # since the first name should reference the passed record
      reflection_path = self.trace_path.split(/\./)
      reflection_path.shift
      
      # set the current evaluated object and iterate over all reflection path tokens
      evaluated = record
      while reflection_path.length > 0
        token = reflection_path.shift
        if(token.blank? || evaluated.nil? || !evaluated.respond_to?(token))
          root.log("Step >> '#{evaluated.to_s}'.'#{token}' cant be resolved")
          break
        end
        
        value = evaluated.send(token)
        root.log("Step >> '#{evaluated.to_s}'.'#{token}' is '#{value.to_s}'")
        
        evaluated = value
      end
      
      return value
    end
    
    # Searches for a node in the sub tree with given trace <tt>path</tt>
    def find_by_path path
      path = path.split(".") unless path.is_a?(Array)

      if (path.first == self.name.to_s)
        path.shift
        return self if (path.empty?)
        
        
        children.each do |node|
          result = node.find_by_path(path)
          return result if result
        end
      end
      
      return nil
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
    
    # Reads the given options and applies to the nodes attributes
    def initialize_leaf options = nil
      options ||= {}

      self.searchable   = options[:searchable]
      self.formatable   = options[:formatable]
      self.visible      = options[:visible]
      self.search_value = options[:search_value]
      self.human_name   = options[:human_name]
      self.selectable   = options[:selectable]
      self.proc_block   = options[:proc] if options[:proc].is_a? Proc
    end
    
  end  
end