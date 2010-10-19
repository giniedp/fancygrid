module Fancygrid
  class Field
    include Fancygrid::FieldHelper
    
    attr_accessor :field_name
    attr_accessor :human_name
    attr_accessor :searchable
    attr_accessor :formatable
    attr_accessor :search_value
    attr_accessor :hidden
    
    def finder_select_name
      searchable ? "#{record_table}.#{field_name}" : nil
    end
  end
end