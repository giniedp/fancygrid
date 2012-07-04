module Fancygrid
  module Orm
    class ActiveRecord
      include Fancygrid::Orm::SqlGenerator

      def execute resource_class, &block
        query = resource_class.where({})

        if self.query_options[:select].present?
          query = query.select(self.query_options[:select])
        end
        
        if self.query_options[:conditions].present?
          query = query.where(self.query_options[:conditions])
        end
        
        if self.query_options[:order].present?
          query = query.order(self.query_options[:order])
        end
        
        if block_given?
          wrapper = Fancygrid::ObjectWrapper.new(query)
          yield wrapper 
          query = wrapper.object
        end
        
        count = query.count
        
        if !self.query_options[:offset].nil? && !self.query_options[:limit].nil?
          query = query.offset(self.query_options[:offset])
          query = query.limit(self.query_options[:limit])
        end

        return query.to_a, count
      end
            
    end
  end
end
