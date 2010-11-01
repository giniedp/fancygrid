require 'ftools'

module Fancygrid
  
  module Helper    
    
    def fancygrid_for(name, klass = nil, table_name = nil)
      store_name = name.to_param
      @fancygrid ||= {}
      @fancygrid[store_name] ||= Grid.new(name, klass, table_name, params)
      yield @fancygrid[store_name] if block_given?

      @fancygrid[store_name].save
    end
    
    def fancyvalue_for(record, leaf)
      value = leaf.value_from(record)
      return value unless leaf.formatable

      template = leaf.root.custom_cells_template
      template ||= Fancygrid::Grid.cells_template
      render( 
        :file => template, 
        :locals => { 
          :grid => leaf.root, :record => record, :cell => leaf, :value => value 
        }
      )
    end
       
    def fancy_rendering_for(record, leaf)
      template = leaf.root.custom_cells_template
      template ||= Fancygrid::Grid.cells_template
      render( 
        :file => template, 
        :locals => { 
          :grid => leaf.root, :record => record, :cell => leaf, :value => record
        }
      )
    end
     
    def fancygrid(name, data = nil)
      fancygrid_instance = fancygrid_for(name)
      fancygrid_instance.data = data if data

      case fancygrid_instance.grid_type.to_s
      when "table"
        render(
          :file   => Fancygrid::Grid.table_template, 
          :locals => { :fancygrid => fancygrid_instance })
      when "list"
        render(
          :file   => Fancygrid::Grid.list_template, 
          :locals => { :fancygrid => fancygrid_instance })
      else
        raise "grid type '#{fancygrid_instance.grid_type}' is not supported. Please specify 'table' or 'list'"
      end

    end
    
    def fancygrid_page_opts
      {
        :selection => [5, 10, 15, 20, 25, 30, 40, 50],
        :selected => (params[:pagination] and params[:pagination][:per_page] or 20)
      }
    end
    
  end

end