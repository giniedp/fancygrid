require 'ftools'

module Railsgrid
  
  module TableHelper    
    def railsgrid_for name
      name = name.classname.underscore if name.is_a?(Class)
      name = name.to_s
      
      @railsgrid ||= {}
      @railsgrid[name] ||= Table.new(name)
      if block_given?
        yield @railsgrid[name]
      end
      @railsgrid[name].save
    end
    
    def railsgrid_results name
      name = name.to_s
      if block_given?
        railsgrid_for(name).run_query(params).values.each do |item| yield item end
      else
        railsgrid_for(name).run_query(params).values
      end
    end
    
    def railsgrid_result_values name, item
      name = name.to_s
      if block_given?
        railsgrid_for(name).values(item, params) do |item, col|
          render :file => Railsgrid::Table.cells_template, :locals => { :item => item, :column => col }
        end.each do |value| yield value end
      else
        railsgrid_for(name).values(item, params)
      end
    end
    
    def railsgrid name
      render :file => Railsgrid::Table.frame_template, :locals => { :railsgrid => railsgrid_for(name) }
    end
    
    def railsgrid_page_opts
      {
        :selection => [5, 10, 15, 20, 25, 30, 40, 50],
        :selected => (params[:pagination] and params[:pagination][:per_page] or 20)
      }
    end
  end

end