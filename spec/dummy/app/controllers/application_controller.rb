class ApplicationController < ActionController::Base

  protect_from_forgery
    
  def index
    if Project.count < 10
      10.times do |i|
        Project.create :title => "Project #{i}"
      end
    end
    
    projects_grid = fancygrid_for :projects, :builder => MyGrid do |grid|
      grid.ajax_url = "/index.html"
      grid.paginate = request.format.html?
      grid.find
    end
    
    respond_to do |format|
      format.html { render }
      format.json { render :json => projects_grid.records }
      format.xml { render :xml => projects_grid.dump_records }
    end
    
    Rails.logger.debug session.inspect
  end
end

class MyGrid < Fancygrid::Grid
  
  def apply_options(options)
    super
    
    self.attributes :id, :title
    self.columns :hash, :object_id
    #self.components -= [:search_bar]
    self.components += [:sort_window]
    self.ajax_url = "/"
    self.ajax_type = :get
    
    self.search_filter "projects.title", [["-- choose --", ""], [:foo, :foo], [:bar, :bar]]
  end

end
