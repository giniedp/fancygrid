module Fancygrid#:nodoc:

  class Grid < Fancygrid::Node
    
    # Collection of all defined columns.
    attr_accessor :leafs
    
    # The grids view state.
    attr_accessor :view_state
    
    # The class of the database connector implementation to be used.
    attr_accessor :orm
    
        
    # The result of the database query. This is the data that is going 
    # to be rendered.
    attr_accessor :records

    # Number of matching records. This is displayed in the pagination.
    attr_accessor :record_count
    
    # Url for the ajax callback.
    attr_accessor :ajax_url
    
    # The request method for the ajax callback e.g. GET or POST.
    attr_accessor :ajax_type
    
    # Array of fancygrid component names that are going to be rendered.
    attr_accessor :components
    
    
    # If true then hides the search bar, but keeps it enabled.
    attr_accessor :hide_search
    
    # Array of enabled search operators.
    attr_accessor :search_operators
    
    # The default search operator.
    attr_accessor :search_operator
        
    # Specifies whether pagination is enabled or not.
    attr_accessor :paginate
    
    # Array of select options for per page drop down.
    attr_accessor :per_page_values
    
    # The default value for the per page drop down.
    attr_accessor :per_page_value

    # If pagination is enabled this value holds the total number of 
    # available data pages.
    attr_accessor :page_count
    
    # Options that have been passed to initialize the fancygrid.
    attr_accessor :options
    
    # Initializes the fancygrid
    #
    def initialize(name, options = {})
      self.options = Fancygrid.default_options.merge(options)
      super(nil, name, self.options)
      self.apply_options(self.options)
    end
    
    # Applies the given options and sets default values
    #
    def apply_options(options)
      self.leafs            = []
      self.view_state       = Fancygrid::ViewState.new(options.fetch(:state_hash, {}))
    
      self.records          = []
      self.record_count     = 0
      self.orm              = options[:orm].classify.constantize
                     
      self.ajax_url         = nil
      self.ajax_type        = options[:ajax_type] 
      self.components       = options[:components]
      
      self.hide_search      = options[:hide_search]
      self.search_operators = options[:search_operators]
      self.search_operator  = options[:search_operator]
      
      self.per_page_values  = options[:per_page_values]
      self.per_page_value   = self.view_state.pagination_per_page(options[:per_page_value])
      self.paginate         = true
      self.page_count       = 0
    end
    
    def find &block
      self.collect_columns
      
      query_options = {}
      query_options[:grid]       = self
      query_options[:select]     = self.leafs.select { |leaf| leaf.selectable }.map{ |leaf| leaf.identifier }
      query_options[:conditions] = self.view_state.conditions
      query_options[:operator]   = self.view_state.operator

      if self.paginate
        query_options[:pagination] = self.view_state.pagination_options(1, self.per_page_value)
      end
      
      self.records, self.record_count = self.orm.new(query_options).execute(resource_class, &block)
      self.page_count = (self.record_count.to_f / self.per_page_value.to_f).ceil
    end
    
    # Determines whether ajax callbacks are enabled or not
    #
    def dynamic?
      self.ajax_url.present?
    end
    
    # Determines whether the given component is enabled or not.
    #
    def component?(name)
      self.components.include?(name)
    end
    
    # Determines whether the simple search component is enabled.
    #
    def simple_search?
      dynamic? && component?(:search_bar)
    end
    
    # Determines whether the complex search component is enabled.
    #
    def complex_search?
      dynamic? && component?(:search)
    end
    
    # Determines whether the top control bar component is enabled.
    #
    def top_control?
      dynamic? && component?(:top_bar)
    end
    
    # Determines whether the bottom control bar component is enabled.
    #
    def bottom_control?
      dynamic? && component?(:bottom_bar)
    end
    
    # Determines whether the sort window component is enabled.
    #
    def sort_window?
      dynamic? && component?(:sort_window)
    end   

    # Collects and returns all columns that are marked to be visible.
    # The collection is sorted by the column position attribute.
    #
    def visible_columns
      @visible_columns ||= leafs.select { |leaf| 
        leaf.visible 
      }.sort { |a, b| 
        a.position <=> b.position 
      }
    end
    
    # Collects and returns all columns that are marked to be hidden.
    # The collection is sorted by the column position attribute.
    #
    def hidden_columns
      @hidden_columns ||= leafs.select { |leaf| 
        leaf.hidden 
      }.sort { |a, b| 
        a.position <=> b.position 
      }
    end

    # Generates options for dropdown selection to select a column.
    #
    def select_column_options
      leafs.select { |leaf| 
        !leaf.hidden && leaf.searchable 
      }.map { |leaf| 
        [leaf.human_name, leaf.identifier] 
      }
    end
    
    # Generates options for dropdown selection to select a comparison operator.
    #
    def select_operator_options
      @select_operator_options ||= self.search_operators.map do |op|
        [ self.operator_human_name(op.to_s), op.to_s ] 
      end
    end
    
    # Gets the human readable name for given comparison operator.
    #
    def operator_human_name(name)
      I18n.t(:"search.operator.#{name}", {
        :default => name.humanize, 
        :scope => Fancygrid.i18n_scope
      })
    end
    
    # Sets the search options for given column.
    #
    def search_filter column, collection
      node = self.children.select { |leaf| leaf.identifier == column }.first
      node.search_options = Array(collection).map { |v| v.is_a?(Array) ? v : [v.to_s, v.to_s]}
    end
    
    # Builds the javascript options for the javascript part of fancygrid.
    #
    def js_options
      {
        :ajaxUrl => self.ajax_url,
        :ajaxType => self.ajax_type,
        :name => self.name,
        :page => self.view_state.pagination_page,
        :perPage => self.per_page_value
      }.to_json.gsub("<|>", "")
    end
    
    # Reorganizes the defined columns and post fixes some options
    #
    def collect_columns
      leafs.clear
      super(leafs)
      leafs.each do |leaf|
        leaf.position = self.view_state.column_option(leaf, :position, leaf.position).to_i
        leaf.width    = self.view_state.column_option(leaf, :width,    leaf.width)
        leaf.visible  = self.view_state.column_option(leaf, :visible, leaf.visible).to_s == "true"
        
        leaf.search_operator = self.view_state.column_condition(leaf, :operator, leaf.search_operator)
        leaf.search_value    = self.view_state.column_condition(leaf, :value,    leaf.search_value)
      end
      leafs.sort! { |a, b| a.position <=> b.position }
    end

    # Dumps the fetched records into an array of hashes that
    # can be rendered as xml or cvs. 
    #
    def dump_records
      result = []
      self.records.each do |record|
        result << (dump = {})
        self.visible_columns.each do |col|
          dump[col.identifier] = col.fetch_value_and_format(record)
        end
      end
      return result
    end
  end
end