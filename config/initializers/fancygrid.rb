# Use this setup block to configure all options available in Fancygrid.
Fancygrid.setup do |config|
  
  # Set the path to the table template. The plugin will use its built in 
  # template unless you change it here.
  #
  #config.table_template_path    = Rails.root.join("app/views/fancygrid/base/table_frame.html.haml")
  
  # Set the path to the list template. The plugin will use its built in 
  # template unless you change it here.
  #
  #config.list_template_path     = Rails.root.join("app/views/fancygrid/base/list_frame.html.haml")
  
  # Set the path to the controls template. The plugin will use its built in 
  # template unless you change it here.
  #
  #config.controls_template_path = Rails.root.join("app/views/fancygrid/base/controls.html.haml")
  
  # Set the default cells template name. Default is "cells". Then you must have
  # a template at "app/views/fancygrid/_cells.html.haml"
  #
  #config.default_cells_template_name = "cells"
  
  # if set to true you dont need to specify a gridtemplate, it will be automaticly
  # set to the grids name. For example if your gridname is "foo" you must have
  # a template at "app/views/fancygrid/_foo.html.haml"
  #
  #config.use_grid_name_as_cells_template_name = false
  
  # Specify here whether the search is visible or not when the grid is rendered
  # the first time.
  #
  #config.search_enabled = false
  
  # Set the default grid type. Available values are :table and :list
  # :table will render thedata inside a table. Each record will get its own
  # table row and each attribute its own cell/column.
  # :list will render each record inside an unordered list as an li element.
  # you must provide a rendering block or a template to render each record.
  #
  #config.default_grid_type = :table
  
  # Set the internationalization namespace where the plugin will retrieve the
  # grids column names.
  #
  #config.i18n_tables_prefix = "fancygrid.tables"
  
end