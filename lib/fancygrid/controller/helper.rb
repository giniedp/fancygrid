module Fancygrid  
  module Controller
    module Helper
      include ActionView::Helpers::TextHelper
            
      # Creates a fancygrid instance for the given model name
      def fancygrid_for(name, options = {})#:yields: grid
        persist_state = (options.delete(:persist) == true)
        state_hash = resolve_fancystate_hash(name, persist_state)
        
        klass = options.fetch(:builder, Fancygrid::Grid)
        instance = klass.new(name, options.merge(:state_hash => state_hash))      
        
        @fancygrid_collection ||= HashWithIndifferentAccess.new
        @fancygrid_collection[name] = instance
        
        yield instance if block_given?
        return instance
      end
    
      def resolve_fancystate_hash(name, persist_state = false)
        state_hash = params.fetch(:fancygrid, {}).fetch(name, nil)
        
        if persist_state
          if state_hash.nil?
            state_hash = load_fancystate_hash(name)
          else
            store_fancystate_hash(name, state_hash)
          end
        end
        
        return state_hash || HashWithIndifferentAccess.new
      end
        
      # Loads a fancygrid state for given name
      def load_fancystate_hash(name)
        session.fetch("fancygrid_#{name}", HashWithIndifferentAccess.new)
      end
          
      # Stores the given fancygrid state under given name
      def store_fancystate_hash(name, state)
        session["fancygrid_#{name}"] = state
      end
    end
  end
end