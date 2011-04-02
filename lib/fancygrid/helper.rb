require "active_support/hash_with_indifferent_access"

module Fancygrid
  
  module Helper    
    
    def fancygrid_params(name)
      opts = params[:fancygrid] || HashWithIndifferentAccess.new({})
      opts[name]
    end
    
    def fancygrid_remote_call?(name)
      !fancygrid_params(name).nil?
    end
    
    # Creates a fancygrid instance for the given model name, its class and
    # its table name.
    # === Example
    #    fancygrid_for :users do |grid|
    #      
    #      # specify attributes to display  
    #      grid.attributes( :id, :username, :email )
    #   
    #      # specify the callback url for ajax loading
    #      grid.url = users_path
    #      
    #      # finally call find with some customized find options
    #      grid.find( :order => "users.created_at DESC" )
    #      
    #    end
    def fancygrid_for(name, klass = nil, table_name = nil)#:yields: grid
      raise "block missing" unless block_given?
      
      @fancygrid ||= HashWithIndifferentAccess.new({})
      @fancygrid[name] ||= Grid.new(name, klass, table_name, params)
      
      fancygrid_instance = @fancygrid[name]
      
      yield fancygrid_instance
      
      view_opts = fancygrid_params(name)
      view_opts ||= fancygrid_instance.load_view_proc_evaluate
      
      # load the fancygrid view
      fancygrid_instance.load_view(view_opts || {})
      
      # store the view right back
      fancygrid_instance.store_view_proc_evaluate

      # now the fancygrid setup is complete and the view is loaded
      # run the database query when we are in the remote state
      if !fancygrid_instance.is_static? && fancygrid_remote_call?(name)
        fancygrid_instance.query_for_data
      end
      
      fancygrid_instance.sort_leafs!
    end
    
    # Renders an existing fancygrid for the given name. You can append a rendering block
    # or pass a template name as an option for custom rendering.
    # === Options
    # * <tt>data</tt> - The data to render
    # * <tt>template</tt> - The template to use for custom rendering columns
    # * <tt>url</tt> - The callback url for ajax
    # * <tt>search_visible</tt> - If true, the search will be visible
    # * <tt>hide_top_control</tt> - If true, the top control bar will be hidden
    # * <tt>hide_bottom_control</tt> - If true, the bottom control bar will be hidden
    # * <tt>grid_type</tt> - may be one of <tt>:list</tt> table <tt>:table</tt> to render a list or a table
    def fancygrid(name, options=nil, &block)#:yields: column, record, value
      store_name = name.to_s
      raise "Missing fancygrid for name '#{store_name}'" if(@fancygrid.nil? || @fancygrid[store_name].nil?)
      fancygrid_instance = @fancygrid[store_name]
      
      options ||= {}
      [:data, :template, :url, :search_visible, :hide_top_control, 
       :hide_bottom_control, :grid_type, :search_formats
      ].each do |option|
        fancygrid_instance.send(option.to_s + "=", options[option]) if options[option]
      end
      
      format_block = block_given? ? block : nil
      template = Fancygrid.table_template
      template = Fancygrid.list_template if(fancygrid_instance.grid_type.to_s == "list")
      
      render(:template => template, :locals => { 
        :fancygrid => fancygrid_instance, 
        :cells_block => format_block, :format_block => format_block
      })
    end
    
    # Renders the given <tt>record</tt>, <tt>leaf</tt> and <tt>value</tt> with the
    # leafs template or the passed rendering block. The result is a column cell content.
    def format_fancygrid_value(record, leaf, value=nil, &format_block)
      if block_given?
        capture(leaf, record, value, &format_block)
      else
        render( :template => leaf.root.template, :locals => { 
          :grid => leaf.root, :table => leaf.root,
          :record => record, 
          :cell => leaf, :column => leaf, 
          :value => value 
        })
      end
    end
    alias :fancy_rendering_for :format_fancygrid_value # backward compatibility
    
    # Returns the <tt>value</tt> of the given <tt>leaf</tt> if it is not <tt>:formatable</tt>.
    # Otherwie the <tt>leaf</tt> ist <tt>value</tt> and the <tt>record</tt> will
    # be passed to the <tt>format_fancygrid_value</tt> method to render and format
    # the value. The result is a column cell content.
    def render_fancygrid_leaf(record, leaf, &format_block)
      value = leaf.value_from(record)
      return value if(!leaf.formatable && leaf.root.grid_type == :table)
      format_fancygrid_value(record, leaf, value, &format_block)
    end
    alias :fancyvalue_for :render_fancygrid_leaf # backward compatibility

    def fancygrid_button name, translate_scope, default, alt=nil
      title = I18n.t(translate_scope, :default => default, :scope => Fancygrid.i18n_scope)
      alt ||= title
      image_tag('/images/fancygrid/spacer.gif', :size => '16x16', :class => "#{name} fg-button", :title => title, :alt => title ).html_safe
    end
  end

end