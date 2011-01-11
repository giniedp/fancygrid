module Fancygrid#:nodoc:
  
  class Grid < Fancygrid::Node
    
    # Url for the ajax callback.
    attr_accessor :url
    
    # Collection of all fancygrid leafs. These are instances of Fancygrid::Node
    # and define the columns of a table. They may refer to an attribute or a
    # method or a renderable cell of a model
    attr_accessor :leafs
    
    # The database query that is sent to the database. This is only used for ajax
    # tables.
    attr_accessor :query
    
    # Collection of toolbars to render. Toolbars are collection of custom
    # buttons with custom functionality. (This is currenty not implemented)
    attr_accessor :toolbars
    
    # The current POST or GET parameters.
    attr_accessor :request_params
    
    # The result of the database query. This is the data that is going to be rendered.
    attr_accessor :dataset

    # Number of possible matching results.
    attr_accessor :resultcount
    
    # The template name that is used to render this grid.
    attr_accessor :template
    
    # Enables or disables the input fields for simple search.
    attr_accessor :search_enabled
    
    # Enables or disables the rendering of the top control bar.
    attr_accessor :hide_top_control
    
    # Enables or disables the rendering of the bottom control bar.
    attr_accessor :hide_bottom_control
    
    # Specifies the rendering strategy. May be one of 'table' or 'list'
    attr_accessor :grid_type
    
    # Sepcifies whether the data is fetched before the grid is rendered or not
    # If set to false the fancygrid wont query for data and render itself
    # on first call. It will rather send an ajax request to collect and
    # display the data in the background.
    attr_accessor :instant_fetch_data
    
    # Order and visibility definition for each column
    attr_accessor :view
    
    # Initializes the grid using the following parameters
    # Usually you only have to specify the *name* for the grid. Fancygrid will
    # try to resolve the models class and its table name.
    def initialize(name, klass = nil, table_name = nil, params = nil)
      super(self, nil, name)
      initialize_node(name, klass, table_name)
      
      self.url            = nil
      self.leafs          = []
      self.dataset        = nil
      self.resultcount    = 0

      self.toolbars       = {}
      self.query          = {}
      self.request_params = (params || {})
      self.instant_fetch_data = false
      
      self.grid_type      = Fancygrid.default_grid_type
      self.search_enabled = Fancygrid.search_enabled
      
      if Fancygrid.use_grid_name_as_cells_template
        self.template = name.to_s 
      else
        self.template = Fancygrid.cells_template
      end
    end
    
    # Returns true if the callback url is blank, that is when no ajax 
    # functionality is wanted.
    def is_static?
      self.url.blank?
    end
    
    # Adds a button that should be rendered in the control bars. (Currently not supportde)
    def button toolbar_name, button_name, button_value
      # Buttons are currently not supported
    end
    
    # Builds the query sends it to the database if this is an ajax call or
    # *instant_fetch_data* is set to true.
    def find(options = nil)
      raise "calling 'find' twice or after 'data=' is not allowed" unless dataset.nil?
      options ||= {}
      leafs.compact!
      
      params = request_params["fancygrid"] || {}
      params = params[self.name] || {}
      # Query generator
      query = {
        :select => self.leafs.map{|leaf| leaf.select_name }.compact,
        :conditions => params[:conditions],
        :pagination => params[:pagination],
        :order => params[:order]
      }
      generator = Fancygrid::QueryGenerator.new(options)

      self.query = generator.evaluate(query)

      query_for_data if (!params.empty? || self.instant_fetch_data)
    end

    # Iterates over all leafs and yields only when a leaf is visible
    def each_leaf
      leafs.compact!
      
      leafs.each do |leaf|
        yield leaf if leaf.visible
      end
    end
    
    # Sets a custom dataset that should be rendered. Also blanks out the
    # callback url so no ajax request will be made.
    def data= data
      leafs.compact!
      
      self.dataset = data.to_a
      self.url = nil
    end
    
    # Runs the current query and caches the result data
    def query_for_data
      if self.record_klass < ActiveRecord::Base
        self.dataset = self.record_klass.find(:all, self.query)
        
        count_query = self.query.reject do |k, v| 
          [:limit, :offset, :order].include?(k.to_sym )
        end
        self.resultcount  = self.record_klass.count(:all, count_query)
        
      elsif self.record_klass < ActiveResource::Base
        self.dataset = self.record_klass.find(:all, :params => self.query)
        self.resultcount = self.dataset.delete_at(self.dataset.length - 1).total
      end
      
      if self.resultcount.respond_to?(:length)
        self.resultcount  = self.resultcount.length 
      end

    end
    
    # Inserts a given node into the leafs collection. If a view is loaded
    # the node will be inserted in its right place.
    def insert_node(node)
      raise "Node must be a leaf" unless node.is_leaf?
      if (self.view && self.view[node.trace].is_a?(Hash))
        node_opts = self.view[node.trace]
        
        node.search_value = node_opts[:value].to_s
        node.position = node_opts[:position].to_i
        node.visible = node_opts[:visible] && node.visible
        leafs.insert(node.position, node)
      else
        leafs << node
      end
    end
    
    # Takes the given view hash and aligns the leafs respecting the view definitions
    def load_view view
      raise "a Hash was expected but #{view.class} given" unless view.is_a? Hash
      self.view = view
      
      new_leafs = self.leafs
      self.leafs = []
      new_leafs.each do |leaf|
        insert_node(leaf)
      end
    end
    
    # Creates a view hash of the current grid state and current search request
    # You can use that hash to load the grids view state
    def dump_view
      leafs.compact!
      
      # get the current condition url parameters
      params = request_params["fancygrid"] || {}
      params = params[self.name] || {}
      params = params["conditions"] || {}
      
      # create the search value mapping
      search_value_mapping = {}
      params.each do |table_name, columns|
        columns.each do |cell_name, cell_value|
          tag_name = "#{table_name}[#{cell_name}]"
          search_value_mapping[tag_name] = cell_value
        end
      end
      
      # build the view state from current leafs using the search value mapping
      dump = {}
      position = 0
      self.leafs.each do |node|
        dump[node.trace] = {
          :position => position,
          :visible => node.visible,
          :value => search_value_mapping[node.tag_name]
        }
        position += 1
      end
      
      dump
    end
    
    # Builds the javascript options for the javascript part of fancygrid
    def js_options
      {
        :url => self.url,
        :name => self.name,
        :isStatic => self.is_static?,
        :gridType => self.grid_type,
        :searchEnabled => self.search_enabled,
        :hideTopControl => self.hide_top_control,
        :hideBottomControl => self.hide_bottom_control,
        :instantFetchData => self.instant_fetch_data
      }.to_json
    end
  end
end