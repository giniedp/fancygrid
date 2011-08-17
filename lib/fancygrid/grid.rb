module Fancygrid#:nodoc:
  
  class Grid < Fancygrid::Node
    
    # Collection of all fancygrid leafs. These are instances of Fancygrid::Node
    # and define the columns of a table. They may refer to an attribute or a
    # method or a renderable cell of a model
    attr_accessor :leafs
    
    # The database query that is sent to the database.
    attr_accessor :query
    
    # The current POST or GET parameters.
    attr_accessor :request_params
    
    # The result of the database query. This is the data that is going to be rendered.
    attr_accessor :dataset

    # Number of possible matching results.
    attr_accessor :resultcount
    
    # Order and visibility definition for each column
    attr_accessor :view
    
    
    
    # Url for the ajax callback.
    attr_accessor :url
    
    # the request type for the ajax callback
    attr_accessor :ajax_type
    
    # enables or disables the sort window
    attr_accessor :enable_sort_window
    
    # The template name that is used to render this grid.
    attr_accessor :template
    
    # Enables or disables the input fields for simple search.
    attr_accessor :search_visible
    
    # Specifies the type of the search. Must be one of "simple" or "complex"
    attr_accessor :search_type
    
    # Specifies a set of enabled search operators
    attr_accessor :search_operators
    
    # Enables or disables the rendering of the top control bar.
    attr_accessor :hide_top_control
    
    # Enables or disables the rendering of the bottom control bar.
    attr_accessor :hide_bottom_control
    
    # Specifies the rendering strategy. May be one of 'table' or 'list'
    attr_accessor :grid_type
    
    # Spcified the select options for per page drop down
    attr_accessor :per_page_options
    
    # Spcified theselected value in the per page drop down
    attr_accessor :per_page_selection
    
    # Specifies the search options for search input fields
    attr_accessor :search_formats
    
    
    
    
    # Initializes the root node of the fancygrid tree.
    def initialize(name, klass = nil, table_name = nil, params = nil)
      super(self, nil, name)
      initialize_node(name, klass, table_name)
      
      self.url              = nil
      self.ajax_type        = :get
      self.enable_sort_window = false
      self.leafs            = []
      self.dataset          = nil
      self.resultcount      = 0

      self.query            = {}
      self.request_params   = (params || {})
      
      self.grid_type        = Fancygrid.default_grid_type
      self.search_visible   = Fancygrid.search_visible
      self.search_type      = Fancygrid.default_search_type
      self.search_operators = Fancygrid.search_operators
      self.search_formats   = {}
      
      if Fancygrid.use_grid_name_as_cells_template
        self.template = File.join(Fancygrid.cells_template_directory.to_s, name.to_s)
      else
        self.template = File.join(Fancygrid.cells_template_directory.to_s, Fancygrid.cells_template.to_s)
      end
      
      self.per_page_options = Fancygrid.default_per_page_options
      self.per_page_selection = Fancygrid.default_per_page_selection
      
      view_opts = self.request_params[:fancygrid] || {}
      view_opts = view_opts[self.name]
            
      self.load_view(view_opts || {})
    end
    
    # Inserts a given node into the leafs collection.
    #
    def insert_node(node)
      raise "Node must be a leaf" unless node.is_leaf?
      if (self.view)        
        node.position = self.view.get_node_position(node)
        node.visible = self.view.get_node_visibility(node)
        node.search_value = self.view.get_node_search_value(node)
      end
      leafs << node
    end
    
    # Sorts the leafs by position attribute
    #
    def sort_leafs!
      leafs.sort! { |a, b| a.position.to_i <=> b.position.to_i }
    end
    
    # Takes the given view hash and aligns the leafs using the passed view definitions
    #
    def load_view options
      options ||= {}
      options = options[:fancygrid] || options
      options = options[self.name] || options
      self.view = Fancygrid::View.new(options)
      
      # reorder current leafs
      new_leafs = self.leafs
      self.leafs = []
      new_leafs.each do |leaf|
        insert_node(leaf)
      end
    end
    
    # Yields a query generator which should be used to build a find query
    #
    # == Options
    # The options are the same as in active record finder method
    # * <tt>:conditions</tt> - An SQL fragment like “administrator = 1”, ["user_name = ?", username], or ["user_name = :user_name", { :user_name => user_name }]
    # * <tt>:order</tt> - An SQL fragment like “created_at DESC, name”.
    # * <tt>:group</tt> - An attribute name by which the result should be grouped. Uses the GROUP BY SQL-clause.
    # * <tt>:having</tt> - Combined with :group this can be used to filter the records that a GROUP BY returns. Uses the HAVING SQL-clause.
    # * <tt>:limit</tt> - An integer determining the limit on the number of rows that should be returned.
    # * <tt>:offset</tt> - An integer determining the offset from where the rows should be fetched. So at 5, it would skip rows 0 through 4.
    # * <tt>:joins</tt> - Either an SQL fragment for additional joins like “LEFT JOIN comments ON comments.post_id = id” (rarely needed), named associations in the same form used for the :include option, which will perform an INNER JOIN on the associated table(s), or an array containing a mixture of both strings and named associations. If the value is a string, then the records will be returned read-only since they will have attributes that do not correspond to the table’s columns. Pass :readonly => false to override.
    # * <tt>:include</tt> - Names associations that should be loaded alongside. The symbols named refer to already defined associations. See eager loading under Associations.
    # * <tt>:select</tt> - By default, this is “*” as in “SELECT * FROM”, but can be changed if you, for example, want to do a join but not include the joined columns. Takes a string with the SELECT SQL fragment (e.g. “id, name”).
    # * <tt>:from</tt> - By default, this is the table name of the class, but can be changed to an alternate table name (or even the name of a database view).
    # * <tt>:readonly</tt> - Mark the returned records read-only so they cannot be saved or updated.
    # * <tt>:lock</tt> - An SQL fragment like “FOR UPDATE” or “LOCK IN SHARE MODE”. :lock => true gives connection’s default exclusive lock, usually “FOR UPDATE”.
    def find(options={})#:yields: generator
      raise "calling 'find' twice or after 'data=' is not allowed" unless dataset.nil?
      
      # don not process same or equal leafs twice
      leafs.compact!
      
      # get the parameters for this grid instance, they are mapped like this { :fancygrid => { :gird_name => ..options.. }}
      params = request_params[:fancygrid] || {}
      params = params[self.name] || {}
      
      # build default query hash
      url_options = {
        :select => self.leafs.map{ |leaf| leaf.select_name }.compact,
        :conditions => params[:conditions],
        :pagination => params[:pagination],
        :operator => params[:operator]
      }
      
      generator = Fancygrid::QueryGenerator.new(url_options)
      generator.parse_options(options)
      yield(generator) if block_given?
      
      generator.order(self.view.get_sort_order)
      
      self.query = generator.query
    end
    
    # Sets a custom dataset that should be rendered.Blanks out the
    # callback <tt>url</tt> so no ajax request will be made.
    #
    def data= data
      leafs.compact!
      
      self.dataset = data.to_a
      self.url = nil
    end
    
    # Runs the current query and caches the resulting data
    #
    def query_for_data
      if self.record_klass < ActiveRecord::Base
        self.dataset = self.record_klass.find(:all, self.query)
        
        count_query = self.query.reject do |k, v| 
          [:limit, :offset, :order].include?(k.to_sym )
        end
        self.resultcount = self.record_klass.count(:all, count_query)
        
      elsif self.record_klass < ActiveResource::Base
        self.dataset = self.record_klass.find(:all, :params => self.query)
        self.resultcount = self.dataset.delete_at(self.dataset.length - 1).total
      else
        raise "Unable to query for data. Supported base classes are 'ActiveRecord::Base' and 'ActiveResource::Base' but '#{self.record_klass}' was given"
      end
      
      self.resultcount = self.resultcount.length  if self.resultcount.respond_to?(:length)
    end
    
    
    
    
    
    # Returns true if the callback url is blank, that is when no ajax 
    # functionality is wanted.
    def is_static?
      self.url.blank?
    end
    
    # Determines whether the grid instance is initialized with simle search
    #
    def has_simple_search?
      self.search_type.to_s == "simple" && !self.is_static?
    end
    
    # Determines whether the grid instance is initialized with complex search
    #
    def has_complex_search?
      self.search_type.to_s == "complex" && !self.is_static?
    end
    
    # Determines whether the grid instance displays the top control bar
    #
    def has_top_control?
      !self.hide_top_control && !self.is_static?
    end
    
    # Determines whether the grid instance displays the bottom control bar
    #
    def has_bottom_control?
      !self.hide_bottom_control && !self.is_static?
    end
    
    # Determines whether the grid instance is able to sort columns
    #
    def has_sort_window?
      !self.is_static? && self.enable_sort_window
    end
    
    def enable_state_caching!
      load_view_proc do |instance|
        opts = session[:fancygrid] || {}
        opts[instance.name.to_s] || {}
      end
      load_view_proc do |instance, dump|
        session[:fancygrid] ||= {}
        session[:fancygrid][instance.name.to_s] = dump
      end
    end
    
    # If a block is given a new Proc is created for later css evaluation
    #
    def css_proc
      @css_proc = Proc.new if block_given?
      @css_proc
    end
    
    # Evaluates the css class for a table row by using the passed record and the ccs_proc of this grid
    #
    def css_proc_evaluate(record)
      @css_proc and @css_proc.call(record) or ""
    end
    
    # Gets and sets a proc for loading a dumped view from session, database or whatever place
    #
    # == Example
    #
    #    fancygrid_for :companies do |g|
    #      g.load_view_proc do |instance|
    #        # load a hash from session, fancygrid will use that to initiate its view
    #        session["fancygrid_#{instance.name.to_s}"] || {}
    #      end
    #    end
    def load_view_proc
      @load_view_proc = Proc.new if block_given?
      @load_view_proc
    end
    
    # Evaluates the <tt>load_view_proc</tt> if available
    #
    def load_view_proc_evaluate
      return load_view_proc.call(self) if load_view_proc.is_a?(Proc)
    end
    
    # Gets and sets a proc for storing a dumped view to session, database or whatever place
    #
    # == Example
    #
    #    fancygrid_for :companies do |g|
    #      g.store_view_proc do |instance, dump|
    #        # store the dump to. The dump comes from the fancygrid view
    #        session["fancygrid_#{instance.name.to_s}"] = dump
    #      end
    #    end
    def store_view_proc
      @store_view_proc = Proc.new if block_given?
      @store_view_proc
    end
    
    # Evaluates the <tt>store_view_proc</tt> if available
    #
    def store_view_proc_evaluate
      store_view_proc.call(self, self.view.dump) if store_view_proc.is_a?(Proc)
    end
    
    
    # Yields each leaf that is visible
    #
    def each_leaf#:yields: leaf
      leafs.compact!
      
      leafs.each do |leaf|
        yield leaf
      end
    end
    
    # Yields each leaf that is visible
    #
    def each_visible_leaf#:yields: leaf
      leafs.compact!
      
      leafs.each do |leaf|
        yield leaf if leaf.visible
      end
    end
    
    # Yields each leaf that is not visible
    #
    def each_hidden_leaf#:yields: leaf
      leafs.compact!
      
      leafs.each do |leaf|
        yield leaf unless leaf.visible
      end
    end
    
    #  Gets all leafs that are visible and searchable
    def serachable_leafs
      leafs.select { |leaf| leaf && leaf.searchable && leaf.visible }.compact
    end
    
    # Yields each fetched record if available
    #
    def each_record#:yields: record
      return unless self.dataset
      self.dataset.each do |record|
        yield record
      end
    end
    

    
    # Builds the javascript options for the javascript part of fancygrid
    def js_options
      {
        :url => self.url,
        :ajaxType => self.ajax_type,
        :name => self.name,
        :isStatic => self.is_static?,
        :gridType => self.grid_type,
        :searchVisible => (self.view.search_visible or self.search_visible),
        :searchType => self.search_type,
        :hideTopControl => self.hide_top_control,
        :hideBottomControl => self.hide_bottom_control,
        :paginationPage => self.view.get_pagination_page,
        :paginationPerPage => self.view.get_pagination_per_page,
      }.to_json
    end
    
    def log(message)#:nodoc:
      #Rails.logger.debug("[FANCYGRID] #{message.to_s}")
    end
  end
end