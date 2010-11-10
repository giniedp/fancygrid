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
       
    def fancy_rendering_for(record, leaf, value=nil &cells_block)
      if block_given?
        capture(leaf.root, record, leaf, value, &cells_block)
      else
        template = leaf.root.custom_cells_template
        template ||= Fancygrid::Grid.cells_template
        render( 
          :file => template, 
          :locals => { 
            :grid => leaf.root, :record => record, :cell => leaf, :value => value
          }
        )
      end
    end
    
    def fancyvalue_for(record, leaf, &cells_block)
      value = leaf.value_from(record)
      return value unless leaf.formatable
      fancy_rendering_for(record, leaf, value, &cells_block)
    end
    
    def fancygrid(name, data = nil, &block)
      fancygrid_instance = fancygrid_for(name)
      fancygrid_instance.data = data if data
      cells_block = block_given? ? block : nil
      
      case fancygrid_instance.grid_type.to_s
      when "table"
        render(
          :file   => Fancygrid::Grid.table_template, 
          :locals => { :fancygrid => fancygrid_instance, :cells_block => cells_block })
      when "list"
        render(
          :file   => Fancygrid::Grid.list_template, 
          :locals => { :fancygrid => fancygrid_instance, :cells_block => cells_block })
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