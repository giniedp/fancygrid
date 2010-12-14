module Fancygrid

  class Grid < Fancygrid::Node
    
    # Url for ajax requests. This is not needed for static tables.
    attr_accessor :url
    
    # Collection of all fancygrid leafs. Leafs build the columns of a table.
    # They may be attributes of a model or custom methods or renderable cells
    attr_accessor :leafs
    
    # The query to send to the database. This is not needed for static tables.
    attr_accessor :query
    
    # Collection of toolbars to render. Toolbars are collection of custom
    # buttons with custom functionality. (This is currenty not implemented)
    attr_accessor :toolbars
    
    # The current http request parameters for this fancygrid instance.
    attr_accessor :request_params
    
    # The database query result. This is the data that is going to be rendered
    attr_accessor :dataset

    # 
    attr_accessor :resultcount
    
    # Path to the template for custom cell rendering of this grid instance
    attr_accessor :custom_cells_template
    
    # Specifies whether the search input fields are visible or not
    attr_accessor :search_enabled
    
    # Specified whether the top control bar is hidden or not
    attr_accessor :hide_top_control
    
    # Specified whether the bottom control bar is hidden or not
    attr_accessor :hide_bottom_control
    
    # Specified the rendering strategy. May be one of 'table' or 'list'
    attr_accessor :grid_type
    
    # Sepcifies whether the data is fetched before the grid is rendered or not
    # If set to false the fancygrid wont query for data and render itself
    # in first place. It will then send an ajax request to collect and
    # display the data.
    attr_accessor :instant_fetch_data
    
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
      self.custom_cells_template = nil
      self.instant_fetch_data = false
      
      self.grid_type      = Fancygrid.default_grid_type
      self.search_enabled = Fancygrid.search_enabled
      if Fancygrid.use_grid_name_as_cells_template_name
        self.template = name.to_s 
      else
        self.template = Fancygrid.default_cells_template_name
      end
    end
    
    def is_static?
      self.url.blank?
    end
    
    def button toolbar_name, button_name, button_value
      # Buttons are currently not supported
    end
    
    def find(options = nil)
      raise "calling 'find' twice or after 'data=' is not allowed" unless dataset.nil?
      
      params = request_params.delete("fancygrid") || {}
      params = params.delete(self.name) || {}
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

    def each_leaf
      leafs.each do |leaf|
        yield leaf if leaf.visible
      end
    end
    
    def data= data
      self.dataset = data.to_a
      self.url = nil
    end
    
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
    
    def save
      self
    end
    
    def template= name
      if name
        self.custom_cells_template = Rails.root.join("app", "views", "fancygrid", "_#{name}.html.haml")
      else
        self.custom_cells_template = nil
      end
    end
    
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