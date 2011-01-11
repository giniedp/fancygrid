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

or for specific tag
    gem 'fancygrid', :git => 'git://github.com/giniedp/fancygrid.git', :tag => "0.3.3"
    
Run
    bundle install
    
and
    rails g fancygrid:install
    
then follow the instructions

Getting started
=====

Basic Setup
==
In any controller in any action you can define a fancygrid for a specific model.
A controller is the place where you define what data should be queried from
the database and what columns will be visible. For example you could define
a table for your users like this:

    # UsersController
    def index
      # setup fancygrid to display users
      fancygrid_for :users do |grid|
        
        # specify attributes to display  
        grid.attributes( :id, :username, :email )

        # specify the callback url for ajax loading
        grid.url = users_path
        
        # finally call find with some customized find options
        grid.find( :order => "users.created_at DESC" )
        
      end
    end
  
In your View you have to render the fancygrid. Use the name that you have used
in your controller

    # app/views/users/index.html.haml
    = fancygrid :users

Static tables
==
If you dont want to have an ajax table, you can set the data directly without
providing a callback url. 

    def index
      fancygrid_for :users do |grid|
        
        # ...
        
        # dont set the url and find options like in the first example
        # instead set the data directly
        grid.data= User.find(:all)
        
      end
    end
   
Table names and model names
==
Usually fancygrid takes the passed name and tries to resolve the models class
and its database table name. If you need to use fancygrid name that is different
from your models name, you can pass the models constant and its table name to
fancygrid

    def index
      fancygrid_for :my_table, User, "users" do |grid|
        
        # ...
        
      end
    end
    
Using methods on a record
==
You are not limited to the models attributes to display in the fancygrid. You can
provide method names to display a models properties
 
    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        # specify methods to call on each record
        grid.methods(:full_name, :some_other_method)
        
        # ...
        
      end
    end
    
You can also use a method trace to call on the model and its property. For example 
to display the number of roles of a user you could do
    
    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        grid.methods( "roles.length" )
        
        # ...
        
      end
    end
    
For more complex output you need to render the cells with custom code
    
Render custom cells
==
For custom cell rendering create a template at some place like *app/views/fancygrid/users.html.haml*
In your fancygrid definition do:

    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        # specify cells that will be rendered with custom code
        grid.rendered(:actions)
        
        # set the templates name 
        grid.template = "fancygrid/users"
        
        # ...
        
      end
    end

In your template you can use the following locals: *grid*, *cell*, *record* and *value*
so you can render your cell like this:

    - case grid.name
    - when :users
      - case cell.name
      - when :actions
        = link_to "Show", user_path(resource)
        = link_to "Edit", edit_user_path(resource)


Display associated data (belongs_to or has_one)
==
To display an associated data you have to tell fancygrid what columns to render.
Also you have to specify more precise find options, otherwise the data wont show up
A user and its contact could be displayed like this

    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        grid.columns_for(:contact) do |c|
          c.attributes( :first_name, :last_name )
        end
        
        # ...
        
        grid.find( :joins => :contact )
        
      end
    end
  
Display associated data (has_many or has_and_belongs_to_many)
==
Like in the previous example you can join an associated model to display its attribtues.
Unfortunately there is a limitation for the has_(and_belongs_to_)many association. 
If you have the following case: 

  class User 
    has_and_belongs_to_many :roles
  
  class Role
    has_and_belongs_to_many :users
  
And you want to create a table where each user has a row for each of his roles,
it wont work. One could try to do the following:

    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        grid.columns_for(:roles) do |r|
          r.attributes( :name )
        end
        
        # ...

      end
    end
    
This will fail, since there are many roles at a single user so :roles in this example
there will be columns for a roles array instead for a role object. The only thing
you one can do is to create a custom renderer for the role name cell and there something 
like this:

    # inside fancygrid setup
    grid.rendered(:user_roles)
    
    # inside the custom renderer
    - case cell.name
    - when :user_roles
      = record.roles.map{ |r| r.name }.join(", ")
      
Conditional output (Implementing a filter)
==
The find options are the same like you put into the find method of ActiveRecord::Base

    User.find(:first, <find_options>)
    
So you can use the conditions to find the wanted data. For example to find all users
with a specific role

    def index  
      fancygrid_for :users do |grid|
      
        # ...
        
        grid.find( :joins => :roles, :conditions => ["roles.name = ?", "admin"], :group => "users.id" )
        
      end
    end

If you have a filter that comes as an url parameter, you have to pass it to the
callback url, so the callback gets the same filter value
    
    def index  
      fancygrid_for :users do |grid|
      
        # ...
        grid.url = users_path(:filter => params[:filter])
        grid.find( :joins => :roles, :conditions => ["roles.name = ?", params[:filter], :group => "users.id" ] )
        
      end
    end
    
Mention that you have to group the results using the users.id

Caching the view state
==
To make your users life easier you can enable the view state caching. This way
the user can search for data, leave the site, come back and have his last
search back on screen. Here is an example of how to store the view in the users session:

    # ensure that there is a hash in the session
    session[:users_table_view_state] ||= {}
    
    fancygrid_for :users do |grid|
      
      # ...
      
      # load the view state into the grid
      grid.load_view(session[:users_table_view_state])
      
      # dump the view state and store back in session
      session[:users_table_view_state] = grid.dump_view()
    end
    
Its up to you where you store the view state. If you have lots of tables i would
recommend to enable database session store.

In a future release fancygrid will allow to sort tables. But you can already
use a part of this feature. You can pass a view state with specific column order 

      session[:users_table_view_state] ||= {
        "users.id" => { :position => 0, :visible => true },
        "users.email" => { :position => 2, :visible => true },
        "contacts.name" => { :position => 1, :visible => true },
      }
      
Similar projects
=====
If this does not fit your needs you may be interested in Flexirails: http://github.com/nicolai86/flexirails

Copyright
=====

Copyright (c) 2010 Alexander Gräfenstein. See LICENSE for details.
