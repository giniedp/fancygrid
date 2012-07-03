module Fancygrid
  
  class Column < Fancygrid::Node
    
    # The column position in table.
    attr_accessor :position
    
    # The column width.
    attr_accessor :width

    # If true, this column is not rendered.
    attr_accessor :hidden


    # If true, a search field is then rendered for this column.
    attr_accessor :searchable
        
    # The current search value for this column.
    attr_accessor :search_value
    
    # The current search operator for this column.
    attr_accessor :search_operator
    
    # The possible search options for this column.
    attr_accessor :search_options
    
    
    # If true, this column is treated as a database column.
    # SQL queries may use the columns name for SELECT statements.
    attr_accessor :selectable
    
    # If true, the root node has a formatter method for this column.
    attr_accessor :formatable
    
    # Value resolver proc for this column.
    attr_accessor :value_proc
    
    
    def initialize(parent, name, options = {})
      super(parent, name, options)
      
      @position        = options.fetch(:position, 0)
      @width           = options.fetch(:width, nil)
      @hidden          = options.fetch(:hidden, false)
      self.visible     = options.fetch(:visible, self.visible)
      
      @searchable      = options.fetch(:searchable, false)
      @search_value    = options.fetch(:search_value, nil)
      @search_operator = options.fetch(:search_operator, nil)
      @search_options  = options.fetch(:search_options, nil)
      
      @selectable      = options.fetch(:selectable, false)
      @value_proc      = options.fetch(:value_proc, nil)
      
      @human_name      = options.fetch(:human_name, nil)
      
      @formatable      = self.root.respond_to?(self.formatter_method)
    end

    # Gets a value indicating whether this column is visible
    # and should be rendered or not.
    #
    def visible
      !@hidden
    end
    
    # Sets a value indication whether this column is visible
    # and should be rendered or not.
    #
    def visible=(value)
      @hidden = !value
    end
    
    # Gets the current sort order for this column.
    #
    def sort_order
      self.root.view_state.column_order(self)
    end
    
    # Gets the method name that is send to the root node
    # to format the value of a column cell
    #
    def formatter_method
      @formatter_method or @formatter_method = "format_" + self.identifier.gsub(".", "_")
    end
    
    # Gets the column identifier.
    # This is the #table_name and #name joined with a '.' (dot)
    #
    def identifier
      @identifier or @identifier = [self.table_name, self.name].join('.')
    end
    
    # Gets a whitespace separated string that is used as css class
    # for the table column. The string contains the #table_name 
    # and the #name of this column.
    #
    def tag_class
      if @tag_class.nil?
        @tag_class = []
        @tag_class << self.table_name
        @tag_class << self.name
        @tag_class << "fg-orderable" if self.searchable
        @tag_class = @tag_class.join(" ")
      end
      @tag_class
    end

    # Gets the internationalization lookup path for this column.
    #
    def i18n_path
      @i18n_path or @i18n_path = [Fancygrid.i18n_scope, :tables, self.name_chain].join(".")
    end
    
    # Gets the default human name for this column
    #
    def default_human_name
      result = self.name.to_s.humanize
      if self.resource_class.respond_to? :human_attribute_name
        self.resource_class.human_attribute_name(self.name, :default => result)
      else
        result
      end
    end
    
    # Gets the internationalized, human readable name for this column.
    #
    def human_name
      @human_name or @human_name = I18n.t(self.i18n_path, :default => default_human_name)
    end
    
    # Fetches a value from given record.
    #
    def fetch_value record
      if self.value_proc
        return value_proc.call(record) 
      else
        chain = self.name_chain.split(".")
        chain.shift

        value = record
        while token = chain.shift
          value = (value.respond_to?(token) ? value.send(token) : nil)
          return nil if value.nil?
        end
        
        return value
      end
    end
   
    # Fetches a value from given record and tries to apply
    # the format method
    #
    def fetch_value_and_format record
      value = fetch_value(record)
      value = self.root.send(self.formatter_method, value) if self.formatable
      return value
    end
    
    # Adds this column to the given collection
    #
    def collect_columns collection
      collection << self
    end
    
    protected    
    def add_child(node)
      raise "columns can not have child elements"
    end  
  end
  
end