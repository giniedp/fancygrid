require 'ftools'

module Fancygrid
  
  module TableHelper    
    
    def fancygrid_for name
      @fancygrid ||= {}
      @fancygrid[name] ||= Table.new(name)
      if block_given?
        yield @fancygrid[name]
      end
      @fancygrid[name].save
    end
    
    def fancygrid_results name
      if block_given?
        fancygrid_for(name).run_query(params).values.each do |item| yield item end
      else
        fancygrid_for(name).run_query(params).values
      end
    end
    
    def fancygrid_result_values name, item
      if block_given?
        fancygrid_for(name).values(item, params) do |item, col|
          render :file => Fancygrid::Table.cells_template, :locals => { :resource => item, :table => col.table, :column => col }
        end.each do |value| yield value end
      else
        fancygrid_for(name).values(item, params)
      end
    end
    
    def fancygrid name
      render :file => Fancygrid::Table.frame_template, :locals => { :fancygrid => fancygrid_for(name) }
    end
    
    def fancygrid_page_opts
      {
        :selection => [5, 10, 15, 20, 25, 30, 40, 50],
        :selected => (params[:pagination] and params[:pagination][:per_page] or 20)
      }
    end
    
  end

end