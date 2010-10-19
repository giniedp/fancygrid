module Fancygrid
  class Result
    attr_accessor :values, :total
    
    def initialize table
      if table.model_class < ActiveRecord::Base
        self.values      = table.model_class.find(:all, table.query)
        count_query = table.query.reject{ |k, v| [:limit, :offset, :order].include? k }
        self.total  = table.model_class.count(:all, count_query)
        self.total  = self.total.length if self.total.respond_to?(:length)
      elsif table.model_class < ActiveResource::Base
        self.values = table.model_class.find(:all, :params => table.query)
        self.total  = self.values.delete_at(values.length - 1).total
        self.total  = self.total.length if self.total.respond_to?(:length)
      else
        self.values = []
        self.total = 0
      end
    end
  end
end