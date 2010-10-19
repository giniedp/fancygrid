module Fancygrid
  class Result
    attr_accessor :values, :total
    
    def initialize table=nil
      
      self.values = []
      self.total  = 0
      
      if table
        if table.record_class < ActiveRecord::Base
          self.values = table.record_class.find(:all, table.query)
          
          count_query = table.query.reject do |k, v| 
            [:limit, :offset, :order].include? k 
          end
          self.total  = table.record_class.count(:all, count_query)
        elsif table.record_class < ActiveResource::Base
          self.values = table.record_class.find(:all, :params => table.query)
          self.total  = self.values.delete_at(values.length - 1).total
        end
        
        if self.total.respond_to?(:length)
          self.total  = self.total.length 
        end
      end
    end
    
    def each
      raise ArgumentError, "Missing block" unless block_given?
      
      values.each do |record|
        yield record
      end
    end
    
  end
end