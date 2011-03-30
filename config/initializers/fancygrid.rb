Fancygrid.setup do |config|
  
  # The path to the table template which is rendered when the grid type is set
  # to :table
  #
  # config.table_template = "fancygrid/base/table_frame"
  
  # The path to the list template which is rendered when the grid type is set 
  # to :list
  #
  # config.list_template = "fancygrid/base/list_frame"
  
  # The path to the controls template which is rendered at the top and the 
  # bottom of a grid
  #
  # config.controls_template = "fancygrid/base/controls"

  # The path to the sort template which defines the view of the column sorting window
  #
  # config.sort_template = "fancygrid/base/sort"
  
  # The path to the search template which defines the view of the complex search
  #
  # config.search_template = "fancygrid/base/search"
  
  # The prefix that is used for every cells template. Default value is 
  # "fancygrid" so every template is expected in the "/app/views/fancygrid"
  # directory
  #
  # config.cells_template_directory = "fancygrid"
  
  # The default cells template name. This is combined with the 
  # 'default_cells_template_directory' to get the full template name
  #
  # config.cells_template = "_cells"
  
  # Specifies the the internationalization namespace where the plugin will 
  # lookup for translations.
  #
  # config.i18n_scope = "fancygrid"
  
  # Value specifying whether the grid name is automatily used as template name
  # to render a grids cells
  #
  # config.use_grid_name_as_cells_template = false
  
  # Value specifying whether the search is visible or not when the grid is 
  # rendered for the first time.
  #
  # config.search_visible = false
  
  # Specifies the default grid type. Available values are :table and :list
  # :table will render the data inside a table. Each record will get its own
  # table row and each attribute its own cell.
  # :list will render each record inside an unordered list as an li element.
  # you must provide a rendering block or a template to render each record.
  #
  # config.default_grid_type = :table
  
  # Default options for number of pages selection
  #
  # config.default_per_page_options = [5, 10, 15, 20, 25, 30, 40, 50]
  
  # Default value for number of pagers selection
  #
  # config.default_per_page_selection = 20
end