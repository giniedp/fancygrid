require "spec_helper"

describe Fancygrid::Column do
  
  class DummyClass
    def self.table_name; "dummy_table"; end;
  end
  
  before :each do
    @node = Fancygrid::Node.new(nil, :project, {})
  end
  
  it "#identifier should combine table_name and column name" do
    @node.column :description
    @node.children.last.identifier.should == "projects.description"
  end
  
  it "#select_name should combine table_name and column name" do
    @node.column :description
    @node.children.last.identifier.should == "projects.description"
  end
  
  it "#tag_class should contain table_name and name" do
    @node.column :description
    @node.children.last.tag_class.include?("projects").should be true
    @node.children.last.tag_class.include?("description").should be true
  end

end
