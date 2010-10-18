module Railsgrid
  class Result
    attr_accessor :values, :total
    
    def initialize table
      if table.model_class < ActiveRecord::Base
        self.values      = table.model_class.find(:all, table.query)
        count_query = table.query.reject{ |k, v| [:limit, :offset, :order].include? k }
        self.total  = 1#       = table.model_class.count(:all, count_query).length
      elsif table.model_class < ActiveResource::Base
        self.values = table.model_class.find(:all, :params => table.query)
        self.total  = self.values.delete_at(values.length - 1).total
      else
        self.values = []
        self.total = 0
      end
    end
  end
end