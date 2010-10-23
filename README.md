Fancygrid
=====

Fancygrid is under heavy development. Things may change frequently.

Requirements
=====
jQuery >= 1.4.2
Rails 3
Haml

Installation
=====
In your gemfile
    gem 'fancygrid', :git => 'git://github.com/giniedp/fancygrid.git'
    
Run
    bundle install
    
and
    rake fancygrid:install
    
then follow the instructions

Howto
=====
In your Controller e.g. UsersController

    def index
      
      # setup fancygrid to display users
      fancygrid_for :users do |grid|
        
        # specify attributes to display  
        grid.attributes( :id, :username, :email )
        
        # specify methods to call on each result
        grid.methods( :full_name )
        
        # specify cells that will be rendered with custom code
        grid.rendered(:actions)
        
        # specify attributes that should be selected but not displayed
        grid.hidden( :role_id )
        
        # build columns for associations
        grid.columns_for :role do |g|
          g.attributes( :id, :name )
        end
        
        # specify the callback url for dynamic loading
        grid.url = users_path
        
        # finally call find with some customized find options
        grid.find( :order => "users.created_at DESC")
        
      end
      
    end
  
In your View e.g. users/index.html.haml

    = fancygrid :users
  
For custom cell rendering create a file at *app/views/fancygrid/_cells.html.haml*
The following locals will be awailable: *grid*, *cell*, *record* and *value* 

    - case grid.name
    - when :users
      - case cell.name
      - when :actions
        = link_to "Show", user_path(resource)
        = link_to "Edit", edit_user_path(resource)

Start your application and enjoy!!!

Static tables
=====
In your Controller e.g. UsersController

    def index
      
      fancygrid_for :users do |grid|
        
        grid.attributes( :id, :username, :email )
        grid.methods( :full_name )
        grid.rendered(:actions)
        grid.hidden( :role_id )
        grid.columns_for :role do |g|
          g.attributes( :id, :name )
        end
        
        # dont set the url and find options like in the first example
        # instead set the data directly
        grid.data= User.find(:all)
      end
      
    end
    
In your View e.g. users/index.html.haml

    = fancygrid :users
    
Similar projects
=====
If this does not fit your needs you may be interested in Flexirails: http://github.com/nicolai86/flexirails

Copyright
=====

Copyright (c) 2010 Alexander Gräfenstein. See LICENSE for details.
