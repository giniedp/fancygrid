require "active_support/hash_with_indifferent_access"

module Fancygrid#:nodoc:
  
  class View
    
    attr_accessor :view
    
    def initialize(view)
      load(view)
    end
    
    def load(view)
      raise "'view' must be a hash" unless view.is_a?(Hash)
      self.view = ActiveSupport::HashWithIndifferentAccess.new(view)
    end
    
    def dump
      return self.view
    end
    
    def get_node_view_options(node)
      opts = self.view[:columns] || {}
      opts = opts[node.record_table_name] || {}
      opts[node.name] or {}
    end
    
    def get_node_position(node)
      opts = get_node_view_options(node)[:position]
      if opts
        opts.to_i
      else
        -1
      end
    end
    
    def get_node_visibility(node)
      opts = get_node_view_options(node)[:visible].to_s
      if %w(true false).include?(opts)
        opts == "true"
      else
        node.visible
      end
    end
    
    def get_node_search_value(node)
      hash = get_node_search_conditions(node).first
      hash and hash[:value]
    end
    
    def get_node_search_conditions(node)
      opts = self.view[:search] || {}
      opts = self.view[:conditions] || {}
      opts = opts[node.record_table_name] || {}
      opts = opts[node.name] || {}
      
      if opts.is_a?(String)
        [{
          :operator => :like,
          :value => opts
        }]
      elsif opts.is_a?(Hash)
        opts.map { |index, value|
          if value.is_a?(Hash)
            {
              :operator => value[:operator].to_s || :like,
              :value => value[:value].to_s
            }
          else
            {
              :operator => :like,
              :value => value.to_s
            }
          end
        }
      elsif opts.is_a?(Array)
        opts
      else
        []
      end
    end
    
    def get_search_operator
      opts = self.view[:search] || {}
      opts = self.view[:operator].to_s
      return opts if %w(all any).include?(opts)
      return :any
    end
    
    def get_sort_order
      opts = self.view[:order] || {}
      if opts[:table] && opts[:column] && opts[:direction]
        "#{opts[:table]}.#{opts[:column]} #{opts[:direction]}"
      else
        nil
      end
    end
    
    def get_pagination_page
      opts = self.view[:pagination] || {}
      opts[:page].to_i
    end
    
    def get_pagination_per_page
      opts = self.view[:pagination] || {}
      opts[:per_page].to_i
    end
  end
end

# :fancygrid => {
#   :<grid-name> => {
#     :columns => {
#       :<table> => {
#         :<column> => {
#           :visible => :<value>, 
#           :position => :<value>
#         }
#       }
#     },
#     :conditions => {
#       :<table> => {
#         :<column> => {
#           :<number> => {
#             :operator => :<operator>, 
#             :value => :<value>
#           }
#         }
#       }
#     }, 
#     :operator => :<operator>,    
#     :order => {
#       :table => :<table>,
#       :column => :<column>,
#       :direction => :<direction>
#     },
#     :pagination => {
#       :page => :<value>, 
#       :per_page => :<value>
#     }
#   }
# }
