# Use this setup block to configure all options available in Fancygrid.
Fancygrid.setup do |config|
  
  # The path to the table template which is rendered when the grid type is set to :table
  #
  # config.table_template = "fancygrid/base/table_frame"
  
  # The path to the list template which is rendered when the grid type is set to :list
  #
  # config.list_template = "fancygrid/base/list_frame"
  
  # The path to the controls template which is rendered at the top and the bottom of a grid
  #
  # config.controls_template = "fancygrid/base/controls"

  # The prefix that is used for every cells template. Default value is "fancygrid/_"
  # so every template is expected in the "/app/views/fancygrid" directory
  #
  # config.cells_template_prefix = "fancygrid/"
  
  # The default cells template name. This is combined with the "default_cells_template_prefix"
  # to get the full template name
  #
  # config.cells_template = "_cells"
  
  # If set to true you dont need to specify a template for your grid, it will be 
  # automaticly set to the grids name. 
  #
  # config.use_grid_name_as_cells_template = false
  
  # Specify here whether the search is visible or not when the grid is rendered
  # the first time.
  #
  # config.search_enabled = false
  
  # Set the default grid type. Available values are :table and :list
  # :table will render the data inside a table. Each record will get its own
  # table row and each attribute its own cell.
  # :list will render each record inside an unordered list as an li element.
  # you must provide a rendering block or a template to render each record.
  #
  # config.default_grid_type = :table
  
  # Set the internationalization namespace where the plugin will retrieve the
  # grids column names.
  #
  # config.i18n_tables_prefix = "fancygrid.tables"
  
  # Default options for number of pages selection
  #
  # config.default_per_page_options = [5, 10, 15, 20, 25, 30, 40, 50]
  
  # Default value for number of pagers selection
  #
  # config.default_per_page_selection = 20
end