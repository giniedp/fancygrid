class ApplicationController < ActionController::Base

  protect_from_forgery
    
  def index
    #Project.destroy_all
    if Project.count < 10
      10.times do |i|
        proj = Project.create :title => "Project #{i}"
        3.times do
          proj.tickets.create!
        end
      end
    end
    
    projects_grid = fancygrid_for :projects, :builder => MyGrid, :persist => true do |grid|
      grid.ajax_url = "/index.html"
      grid.paginate = request.format.html?
      grid.find do |q|
        q.includes :tickets
      end
    end
    
    respond_to do |format|
      format.html { render }
      format.json { render :json => projects_grid.records }
      format.xml { render :xml => projects_grid.dump_records }
    end
  end
end

class MyGrid < Fancygrid::Grid
  
  def apply_options(options)
    super
    
    self.attributes :id, :title
    self.columns :hash, :object_id
    self.columns_for :tickets do |t|
      t.attributes :id
    end
    #self.components -= [:search_bar]
    self.components += [:sort_window]
    #self.ajax_url = "/"
    self.ajax_type = :get
    
    self.search_filter "projects.title", [["-- choose --", ""], [:foo, :foo], [:bar, :bar]]
  end

end
