Fancygrid
=====

Fancygrid is under heavy development. Things may change frequently.

Installation
=====
In your gemfile

    gem 'fancygrid', :git => 'git@github.com:giniedp/fancygrid.git', :branch => 'master'
    
Run
    
    rake fancygrid:install
    
And follow the instructions

Howto
=====
In your Controller e.g. UsersController

    def UsersController < ApplicationController
      def index
        
        # setup and initialize fancygrid to display users
        fancygrid_for :users do |grid|
        
          # setup some default query options
          grid.query.merge!({
            
            :order => ["created_at DESC"]
          })
          
          # specify attributes to display  
          grid.attributes([ :id, :username, :email ])
          
          # specify methods to call on each
          grid.methods( :full_name )
          
          # specify cells that will be rendered with cutom code
          grid.cells(:actions)
          
          # specify the url where this setup is defined
          # here we are in the index method of the users controller
          grid.url = users_path
      
        end
        
      end
    end
  
In your View e.g. users/index.html.haml

    = fancygrid :users
  
For custom cell rendering create a file at *app/views/fancygrid/_cells.html.haml*
The following locals will be awailable: *grid*, *cell* and *resource*

    - case grid.name
    - when :users
      - case cell.name
      - when :actions
        = link_to "Show", user_path(resource)
        = link_to "Edit", edit_user_path(resource)

Start your application and enjoy!!!

Similar projects
=====
If this does not fit your needs you may be interested in Flexirails: http://github.com/nicolai86/flexirails

Copyright
=====

Copyright (c) 2010 Alexander Gräfenstein. See LICENSE for details.
