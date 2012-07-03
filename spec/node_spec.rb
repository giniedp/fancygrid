require "spec_helper"

describe Fancygrid::Node do
  
  class DummyClass
    def self.table_name; "dummy_table"; end;
  end
  
  describe "#initialize" do
    it "should call #to_s on name attribute" do
      Fancygrid::Node.new(nil, :project).name.should == "project"
    end
    
    it "should resolve resource class" do
      Fancygrid::Node.new(nil, :project).resource_class.should == Project
    end
    
    it "should resolve table name" do
      Fancygrid::Node.new(nil, :project).table_name.should == "projects"
    end
    
    it "should override resource class" do
      node = Fancygrid::Node.new(nil, :project, {
        :class => DummyClass
      })
      
      node.resource_class.should == DummyClass
      node.table_name.should == "dummy_table"
    end
    
    it "should override table name" do
      node = Fancygrid::Node.new(nil, :project, { :table_name => "some_table_name" })
      node.table_name.should == "some_table_name"
    end
  
    it "should be the root node when initialized without parent" do
      node = Fancygrid::Node.new(nil, :project)
      node.root.should be node
      node.root?.should be true
    end
  end
  
  describe "#columns_for" do
    
    it "should add child node connect with parent" do
      node1 = Fancygrid::Node.new(nil, :project)
      node2 = node1.columns_for :ticket
    
      node2.parent.should be node1
      node1.children.should include node2    
    end
    
    it "should propagate the root node" do
      node1 = Fancygrid::Node.new(nil, :project)
      node2 = node1.columns_for :ticket
      
      node1.root?.should be true
      node2.root?.should be false
      
      node1.root.should be node2.root
    end
    
    it "#should create and yield Fancygrid::Node" do
      node = Fancygrid::Node.new(nil, :project, {})
      node.columns_for :project do |inner|
        inner.class.should == Fancygrid::Node
      end
      node.children.count.should be 1
    end
  end

  describe "#column" do
    it "should create a Fancygrid::Column and add as child" do
      node = Fancygrid::Node.new(nil, :project, {})
      node.column(:project).class.should == Fancygrid::Column
    end
    
    it "should add a child" do
      node = Fancygrid::Node.new(nil, :project, {})
      node.children.count.should be 0
      node.column(:project)
      node.children.count.should be 1
    end    
  end

  describe "#column" do  
    it "should add multiple columns at once" do
      node = Fancygrid::Node.new(nil, :project, {})
      node.children.count.should be 0
      node.columns :project, :ticket
      node.children.count.should be 2
    end
  end
  
  it "#name_chain should return all names starting from root inclusive" do
    node = Fancygrid::Node.new(nil, :project, {})
    node.columns_for :ticket do |inner|
      inner.name_chain.should == "project.ticket"
    end
    
    node.name_chain.should == "project"
  end
  
end
