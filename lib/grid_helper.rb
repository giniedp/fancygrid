require 'ftools'

module Fancygrid
  
  module GridHelper    
    
    def fancygrid_for(name, klass=nil)
      store_name = name.to_param
      
      @fancygrid ||= {}
      @fancygrid[store_name] ||= Grid.new(name, klass, params)
      if block_given?
        yield @fancygrid[store_name]
      end
      @fancygrid[store_name].save
    end
    
    def fancyrow(fancygrid, record)
      fancygrid.values_for(record) do |cell, value|
        render(
          :file   => Fancygrid::Grid.cells_template, 
          :locals => { :grid => fancygrid, :record => record, :cell => cell, :value => value })
      end
    end
    
    def fancygrid(name)
      render(
        :file   => Fancygrid::Grid.frame_template, 
        :locals => { :fancygrid => fancygrid_for(name) })
    end
    
    def fancygrid_page_opts
      {
        :selection => [5, 10, 15, 20, 25, 30, 40, 50],
        :selected => (params[:pagination] and params[:pagination][:per_page] or 20)
      }
    end
    
  end

end