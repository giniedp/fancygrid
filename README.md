railsgrid
=====


Still in development

Howto
=====
In your gemfile

    gem 'railsgrid', :git => 'git@github.com:giniedp/railsgrid.git', :branch => 'master'
    
In your controller

    def index
      railsgrid_for :job do |table|
        table.query.merge!({
          :order => ["created_at DESC"], :group => "jobs.id"
        })
        table.attributes([ :id, :keyword ])
        table.cells(:action)
        
        table.url = jobs_path
    
      end
    end
  
In your job/index.html.haml

    = railsgrid :job
  
In your railsgrid/_cells.html.haml

    - if column.column_name == "job[action]"
      = link_to "Edit", edit_job_path(item)
 
Or visit http://github.com/nicolai86/flexirails

Copyright
=====

Copyright (c) 2010 Alexander Gräfenstein. See LICENSE for details.
