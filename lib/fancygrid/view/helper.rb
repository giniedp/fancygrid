module Fancygrid  
  module View
    module Helper
      # Renders an existing fancygrid for the given name. A rendering block
      # may be passed to format column values.
      #
      def fancygrid(name, options={}, &block)#:yields: column, record, value
        instance = @fancygrid_collection && @fancygrid_collection[name]
        raise "Unknown fancygrid name: '#{name}'" if instance.nil?
        render :template => instance.options[:base_template], :locals => { :fancygrid => instance, :format_block => block }
      end
      
      # Fetches a value from given record and applies a formatter on it.
      # 
      def render_fancygrid_cell(record, column, &format_block)
        value = column.fetch_value_and_format(record)
        format_fancygrid_value(record, column, value, &format_block)
      end
      
      # Renders the given <tt>record</tt>, <tt>column</tt> and <tt>value</tt> 
      # with the formatter block.
      #
      def format_fancygrid_value(record, column, value=nil, &format_block)
        if block_given?
          if defined?(Haml::Helpers) && is_haml?
            capture_haml(column, record, value, &format_block)
          else
            capture(column, record, value, &format_block)
          end
        #elsif !column.root.cell_template.nil?
        #  render( :template => column.root.cell_template, :inline => true, :locals => { 
        #    :grid => column.root,
        #    :record => record, 
        #    :column => column, 
        #    :value => value 
        #  })
        else
          value
        end
      end
    end
  end
end

