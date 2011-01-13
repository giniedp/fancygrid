require "spec_helper"

describe Fancygrid::Node do

  # builds a test structure with
  # 14 leafs
  # 3 nodes
  # 3 levels
  #
  #     tickets
  #       +- title
  #       +- description
  #       +- status
  #       +- is_finished?
  #       +- actions
  #       +- project_id
  #       +- project
  #            +- title
  #            +- class
  #            +- actions
  #            +- id
  #            +- foo
  #               +- title
  #               +- foo
  #               +- bar
  #               +- id
  #     
  def build_testgrid
    grid = Fancygrid::Grid.new(:ticket)
    grid.attributes(:title, :description, :status)
    grid.methods(:is_finished?)
    grid.rendered(:actions)
    grid.hidden(:project_id)
    grid.columns_for(:project) do |p|
      p.attributes(:title)
      p.methods(:class)
      p.rendered(:actions)
      p.hidden(:id)
      
      p.columns_for(:foo, Project) do |f|
        f.attributes(:title)
        f.methods(:foo)
        f.rendered(:bar)
        f.hidden(:id)
      end
    end
       
    return grid 
  end
  
  it "should build a fancygrid tree" do
    
    grid = build_testgrid  
    grid.children.length.should be 7
    grid.leafs.length.should be 14

  end
  
  it "should find node by path" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").name.should == :ticket
    grid.find_by_path("ticket.title").name.should == :title
    grid.find_by_path("ticket.description").name.should == :description
    grid.find_by_path("ticket.status").name.should == :status
    grid.find_by_path("ticket.is_finished?").name.should == :is_finished?
    grid.find_by_path("ticket.actions").name.should == :actions
    grid.find_by_path("ticket.project_id").name.should == :project_id
    
    grid.find_by_path("ticket.project").name.should == :project
    grid.find_by_path("ticket.project.title").name.should == :title
    grid.find_by_path("ticket.project.class").name.should == :class
    grid.find_by_path("ticket.project.actions").name.should == :actions
    grid.find_by_path("ticket.project.id").name.should == :id
    
    grid.find_by_path("ticket.project.foo").name.should == :foo
    grid.find_by_path("ticket.project.foo.title").name.should == :title
    grid.find_by_path("ticket.project.foo.foo").name.should == :foo
    grid.find_by_path("ticket.project.foo.bar").name.should == :bar
    grid.find_by_path("ticket.project.foo.id").name.should == :id
    
  end
  
  it "should have a fancygrid instance as root" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").root.should be(grid)
    grid.find_by_path("ticket.title").root.should be(grid)
    grid.find_by_path("ticket.description").root.should be(grid)
    grid.find_by_path("ticket.status").root.should be(grid)
    grid.find_by_path("ticket.is_finished?").root.should be(grid)
    grid.find_by_path("ticket.actions").root.should be(grid)
    grid.find_by_path("ticket.project_id").root.should be(grid)
    
    grid.find_by_path("ticket.project").root.should be(grid)
    grid.find_by_path("ticket.project.title").root.should be(grid)
    grid.find_by_path("ticket.project.class").root.should be(grid)
    grid.find_by_path("ticket.project.actions").root.should be(grid)
    grid.find_by_path("ticket.project.id").root.should be(grid)
    
    grid.find_by_path("ticket.project.foo").root.should be(grid)
    grid.find_by_path("ticket.project.foo.title").root.should be(grid)
    grid.find_by_path("ticket.project.foo.foo").root.should be(grid)
    grid.find_by_path("ticket.project.foo.bar").root.should be(grid)
    grid.find_by_path("ticket.project.foo.id").root.should be(grid)
    
  end
  
  it "should be a leaf if has no children" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").is_leaf?.should be(false)
    grid.find_by_path("ticket.title").is_leaf?.should be(true)
    grid.find_by_path("ticket.description").is_leaf?.should be(true)
    grid.find_by_path("ticket.status").is_leaf?.should be(true)
    grid.find_by_path("ticket.is_finished?").is_leaf?.should be(true)
    grid.find_by_path("ticket.actions").is_leaf?.should be(true)
    grid.find_by_path("ticket.project_id").is_leaf?.should be(true)
    
    grid.find_by_path("ticket.project").is_leaf?.should be(false)
    grid.find_by_path("ticket.project.title").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.class").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.actions").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.id").is_leaf?.should be(true)
    
    grid.find_by_path("ticket.project.foo").is_leaf?.should be(false)
    grid.find_by_path("ticket.project.foo.title").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.foo.foo").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.foo.bar").is_leaf?.should be(true)
    grid.find_by_path("ticket.project.foo.id").is_leaf?.should be(true)
    
  end
  
  it "should have a tag name if is a leaf" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").tag_name.should == nil
    grid.find_by_path("ticket.title").tag_name.should == "tickets[title]"
    grid.find_by_path("ticket.description").tag_name.should == "tickets[description]"
    grid.find_by_path("ticket.status").tag_name.should == "tickets[status]"
    grid.find_by_path("ticket.is_finished?").tag_name.should == "tickets[is_finished?]"
    grid.find_by_path("ticket.actions").tag_name.should == "tickets[actions]"
    grid.find_by_path("ticket.project_id").tag_name.should == "tickets[project_id]"
    
    grid.find_by_path("ticket.project").tag_name.should == nil
    grid.find_by_path("ticket.project.title").tag_name.should == "projects[title]"
    grid.find_by_path("ticket.project.class").tag_name.should == "projects[class]"
    grid.find_by_path("ticket.project.actions").tag_name.should == "projects[actions]"
    grid.find_by_path("ticket.project.id").tag_name.should == "projects[id]"
    
    grid.find_by_path("ticket.project.foo").tag_name.should == nil
    grid.find_by_path("ticket.project.foo.title").tag_name.should == "projects[title]"
    grid.find_by_path("ticket.project.foo.foo").tag_name.should == "projects[foo]"
    grid.find_by_path("ticket.project.foo.bar").tag_name.should == "projects[bar]"
    grid.find_by_path("ticket.project.foo.id").tag_name.should == "projects[id]"
    
  end
  
  it "should have a select name if is a leaf and is selectable" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").select_name.should == nil
    grid.find_by_path("ticket.title").select_name.should == "tickets.title"
    grid.find_by_path("ticket.description").select_name.should == "tickets.description"
    grid.find_by_path("ticket.status").select_name.should == "tickets.status"
    grid.find_by_path("ticket.is_finished?").select_name.should == nil
    grid.find_by_path("ticket.actions").select_name.should == nil
    grid.find_by_path("ticket.project_id").select_name.should == "tickets.project_id"
    
    grid.find_by_path("ticket.project").select_name.should == nil
    grid.find_by_path("ticket.project.title").select_name.should == "projects.title"
    grid.find_by_path("ticket.project.class").select_name.should == nil
    grid.find_by_path("ticket.project.actions").select_name.should == nil
    grid.find_by_path("ticket.project.id").select_name.should == "projects.id"
    
    grid.find_by_path("ticket.project.foo").select_name.should == nil
    grid.find_by_path("ticket.project.foo.title").select_name.should == "projects.title"
    grid.find_by_path("ticket.project.foo.foo").select_name.should == nil
    grid.find_by_path("ticket.project.foo.bar").select_name.should == nil
    grid.find_by_path("ticket.project.foo.id").select_name.should == "projects.id"
    
  end
  
  it "have a css class if is a leaf" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").css_class.should == nil
    grid.find_by_path("ticket.title").css_class.should == "tickets title"
    grid.find_by_path("ticket.description").css_class.should == "tickets description"
    grid.find_by_path("ticket.status").css_class.should == "tickets status"
    grid.find_by_path("ticket.is_finished?").css_class.should == "tickets is_finished?"
    grid.find_by_path("ticket.actions").css_class.should == "tickets actions"
    grid.find_by_path("ticket.project_id").css_class.should == "tickets project_id"
    
    grid.find_by_path("ticket.project").css_class.should == nil
    grid.find_by_path("ticket.project.title").css_class.should == "projects title"
    grid.find_by_path("ticket.project.class").css_class.should == "projects class"
    grid.find_by_path("ticket.project.actions").css_class.should == "projects actions"
    grid.find_by_path("ticket.project.id").css_class.should == "projects id"
    
    grid.find_by_path("ticket.project.foo").css_class.should == nil
    grid.find_by_path("ticket.project.foo.title").css_class.should == "projects title"
    grid.find_by_path("ticket.project.foo.foo").css_class.should == "projects foo"
    grid.find_by_path("ticket.project.foo.bar").css_class.should == "projects bar"
    grid.find_by_path("ticket.project.foo.id").css_class.should == "projects id"
    
  end
  
  it "should have an i18n path if is a leaf" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").i18n_path.should == nil
    grid.find_by_path("ticket.title").i18n_path.should_not be nil
    grid.find_by_path("ticket.description").i18n_path.should_not be nil
    grid.find_by_path("ticket.status").i18n_path.should_not be nil
    grid.find_by_path("ticket.is_finished?").i18n_path.should_not be nil
    grid.find_by_path("ticket.actions").i18n_path.should_not be nil
    grid.find_by_path("ticket.project_id").i18n_path.should_not be nil
    
    grid.find_by_path("ticket.project").i18n_path.should == nil
    grid.find_by_path("ticket.project.title").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.class").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.actions").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.id").i18n_path.should_not be nil
    
    grid.find_by_path("ticket.project.foo").i18n_path.should == nil
    grid.find_by_path("ticket.project.foo.title").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.foo.foo").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.foo.bar").i18n_path.should_not be nil
    grid.find_by_path("ticket.project.foo.id").i18n_path.should_not be nil
    
  end
  
  it "should have a trace path" do
    
    grid = build_testgrid
    grid.find_by_path("ticket").trace_path.should == "ticket"
    grid.find_by_path("ticket.title").trace_path.should == "ticket.title"
    grid.find_by_path("ticket.description").trace_path.should == "ticket.description"
    grid.find_by_path("ticket.status").trace_path.should == "ticket.status"
    grid.find_by_path("ticket.is_finished?").trace_path.should == "ticket.is_finished?"
    grid.find_by_path("ticket.actions").trace_path.should == "ticket.actions"
    grid.find_by_path("ticket.project_id").trace_path.should == "ticket.project_id"
    
    grid.find_by_path("ticket.project").trace_path.should == "ticket.project"
    grid.find_by_path("ticket.project.title").trace_path.should == "ticket.project.title"
    grid.find_by_path("ticket.project.class").trace_path.should == "ticket.project.class"
    grid.find_by_path("ticket.project.actions").trace_path.should == "ticket.project.actions"
    grid.find_by_path("ticket.project.id").trace_path.should == "ticket.project.id"
    
    grid.find_by_path("ticket.project.foo").trace_path.should == "ticket.project.foo"
    grid.find_by_path("ticket.project.foo.title").trace_path.should == "ticket.project.foo.title"
    grid.find_by_path("ticket.project.foo.foo").trace_path.should == "ticket.project.foo.foo"
    grid.find_by_path("ticket.project.foo.bar").trace_path.should == "ticket.project.foo.bar"
    grid.find_by_path("ticket.project.foo.id").trace_path.should == "ticket.project.foo.id"
    
  end
  
  
  it "should get attributes from model" do
    ticket = Ticket.new({
      :title => "ticket title",
      :description => "ticket description",
      :status => "ticket status",
      :project => Project.new({ :title => "project title" })
    })
    
    grid = build_testgrid
    grid.find_by_path("ticket.title").value_from(ticket).should == "ticket title"
    grid.find_by_path("ticket.description").value_from(ticket).should == "ticket description"
    grid.find_by_path("ticket.status").value_from(ticket).should == "ticket status"
    grid.find_by_path("ticket.project.title").value_from(ticket).should == "project title"
    
  end
  
  it "should pass the visible option to node" do
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :visible => true )
    grid.find_by_path("ticket.title").visible.should be true
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :visible => false )
    grid.find_by_path("ticket.title").visible.should be false
  end
  
  it "should pass the formatable option to node" do
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :formatable => true )
    grid.find_by_path("ticket.title").formatable.should be true
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :formatable => false )
    grid.find_by_path("ticket.title").formatable.should be false
  end
  
  it "should pass the searchable option to node" do
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :searchable => true )
    grid.find_by_path("ticket.title").searchable.should be true
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :searchable => false )
    grid.find_by_path("ticket.title").searchable.should be false
  end
  
  it "should pass the serach value option to node" do
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :search_value => "title" )
    grid.find_by_path("ticket.title").search_value.should == "title"
    
  end
  
  it "should pass the human name option to node" do
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :human_name => "custom human name" )
    grid.find_by_path("ticket.title").human_name.should == "custom human name"
    
  end
  
  it "should pass the proc option to node" do
    
    ticket = Ticket.new(:title => "ticket title")
    
    grid = Fancygrid::Grid.new(:ticket)
    grid.column(:title, :proc => Proc.new { |t| t.title } )
    grid.find_by_path("ticket.title").proc_block.call(ticket).should == "ticket title"
    grid.find_by_path("ticket.title").value_from(ticket).should == "ticket title"
  end
end