module Fancygrid
  class ObjectWrapper      
    
    # Initializes the object wrapper
    #
    def initialize obj
      @wrapped = obj
    end
    
    # Gets the wrapped object
    #
    def object
      @wrapped
    end
    
    # Sends the missing method to the wrapped object
    # and stores the result as the new wrapped object
    #
    def method_missing(method, *args, &block)
      @wrapped = @wrapped.send(method, *args)
      return self
    end
  end
end