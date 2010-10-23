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
      if leaf.formatable
        template = Fancygrid::Grid.cells_template
        if leaf.root.template
          template = Rails.root.join("app", "views", "fancygrid", "_" + leaf.root.template + ".html.haml")
        end
        render( 
          :file => template, 
          :locals => { 
            :grid => leaf.root, :record => record, :cell => leaf, :value => value 
          }
        )
      else
        value
      end
    end
    
    def fancygrid(name, data = nil)
      fancygrid_instance = fancygrid_for(name)
      fancygrid_instance.data = data if data
      render(
        :file   => Fancygrid::Grid.frame_template, 
        :locals => { :fancygrid => fancygrid_instance })
    end
    
    def fancygrid_page_opts
      {
        :selection => [5, 10, 15, 20, 25, 30, 40, 50],
        :selected => (params[:pagination] and params[:pagination][:per_page] or 20)
      }
    end
    
  end

end