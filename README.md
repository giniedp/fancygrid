## Fancygrid
Fancygrid mades it easy to create and render tables for database records in rails.
### Features
* Ajax data fetch
* Pagination
* Simple search
* Complex search with 17 different conditions
* Column sorting
* View state caching
* ActiveRecord supported. MongoDB coming (some day).
* Column values from attributes, methods, method chains or even custom blocks

### Requirements
* jQuery >= 1.4.2
* jQuery-ui (required if column sorting is wanted)
* Rails 3
* Haml

### Installation
In your gemfile
```ruby
gem 'fancygrid'
```
Run
```console
bundle install
```

If you use Rails3 with asset pipeline enabled, you can just require the javascript and css 
```
// = require fancygrid
```
If your asset pipeline is disabled, you have to copy the assets from the gems lib directory. There is no generator for this task.

## Getting started

### Basic Setup
In any controller in any action you can define a fancygrid for a specific model.
Here is an example for a simple table for the Users model:
```ruby
  # UsersController
  def index
  
    fancygrid_for :users do |g|        
      # specify attributes to display  
      g.attributes :id, :username, :email 
      # specify the callback url for ajax loading
      g.ajax_url = users_path
      # finally call find to query the data
      g.find
    end
  end
```

To render the fancygrid in the view, use the same name that you passed in the setup
```haml
  # app/views/users/index.html.haml
  = fancygrid :users
```

### Static tables
If you dont want to have an ajax table, dont specify the ajax_url. The data will be
queried and the table will be rendered without pagination.
```ruby
  def index
    fancygrid_for :users do |g|
      # ...
      g.attributes :id, :username, :email 
      # don't set the ajax_url and just call find
      g.find
    end
  end
``` 

### Table names and model names
Usually fancygrid tries to resolve the models class and table name from given 
name. If you happen to use namespaced models, you must pass the class as an option.
```ruby
  def index
    fancygrid_for :user, :class => Namespace::User do |g|
      # ...
    end
  end
```

Optionally you can also pass a specific table name. However, if the class responds
to #table_name, this is not necessary.
```ruby
  def index
    fancygrid_for :user, :class => Namespace::User, :table_name => "users" do |g|
      # ...
    end
  end
```

## Define columns
To display attributes as columns use the #attributes method for setup like this:
```ruby
  def index  
    fancygrid_for :users do |g|
      # ...
      g.attributes :id, :email, :created_at
      # ...
    end
  end
```

For everything else use the #columns method. You can have method names,
method chains and procs to resolve column values.
```ruby
  def index  
    fancygrid_for :users do |g|
      # ...
      # methods
      g.columns :full_name, :some_other_method
      # method chains
      g.columns "orders.count"
      # procs
      g.columns :roles do |record|
        record.roles.map(&:name).join(", ")
      end        
      # ...
    end
  end
```
For more complex output you have to format the cell value in the view or a formatter method.

## Columns formatting
Add a block to the fancygrid call in the view. In there you can use a switch condition
on the columns name to determine what to render. Do not forget to add the else case to
render all unformatted values.
```haml
  = fancygrid :users do |column, record, value|
    - case column.name
    - when :actions
      = link_to "Show", user_path(record)
      = link_to "Edit", edit_user_path(record)
    - else
      / this else case is important
      = value
```

## belongs_to or has_one associations 
To define columns for associations, use the #columns_for method.
```ruby
  def index  
    fancygrid_for :users do |g|
      # ...
      g.columns_for :contact do |contact|
        contact.attributes :first_name, :last_name
      end
      # ...
      g.find do |query|
        # eager loading of the association
        query.includes :contact
      end
    end
  end
```

If your association name is different from the models name, pass the model 
class as option.
```ruby
  def index  
    fancygrid_for :users do |g|
      # ...
      g.columns_for :invoice_address, :class => Address do |adr|
        adr.attributes :street, :zipcode, :city
      end
      # ...
    end
  end
```

## has_many or has_and_belongs_to_many associations
If you have Users that has_many Orders, you should rather define a fancygrid 
for the Orders than for Users. However, if it must be a Users table and
you want to search on the associations attributes, you can do that:

```ruby
  def index  
    fancygrid_for :users do |g|
      # ...
      g.columns_for :roles do |roles|
        roles.attributes :name 
      end
      # ...
    end
  end
```
    
The definition is valid, and you can already search for users with a specific
role. But nothing is going to be rendered in the roles.name column. This is
because roles is a collection of records, and not a single record. You can now
format the column in the view like this

```haml
  = fancygrid :users do |column, record, value|
      - case column.identifier
      - when "roles.name"
        = record.roles.map(&:name).join("|")
      - else
        = value
```

Here the column identifier is used to identify the column. This is useful
if you have more columns that are named the same.

## Caching the view state
To make your users life easier you can enable the view state caching. This way
the user can search for data, leave the site, come back and have his last
search back on screen.
```ruby
  def index
    fancygrid_for :users, :persist => true do |grid|
      # ...
    end
  end
```
## Copyright
Copyright (c) 2010 Alexander Graefenstein. See LICENSE for details.
