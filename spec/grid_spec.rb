require "spec_helper"

describe Fancygrid::Grid do
  it "should get table name from model name" do
    grid = Fancygrid::Grid.new(:ticket)
    grid.record_table_name.should == "tickets"
  end
  
  it "should get table name from class constant" do
    grid = Fancygrid::Grid.new(:foo, Ticket)
    grid.record_table_name.should == "tickets"
  end
  
  
end