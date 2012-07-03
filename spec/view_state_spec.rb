require "spec_helper"

describe Fancygrid::ViewState do
  

  #{
  #  :columns => [
  #    { :table => [string], :column => [string], :visible => [bool], :position => [number] }
  #  ]
  #  :conditions => [
  #    { :table => [string], :column => [string], :operator => [string], :value => [string] }
  #  ], 
  #  :conditions_match => ["all"|"any"],
  #  :order => { :identifier => [string], :direction => ["asc"|"desc"|""] },
  #  :pagination => { :page => [number], :per_page => [number] }
  #}

  
  it "should initialize without argument" do
    state = Fancygrid::ViewState.new
  end
  
  it "should initialize with empty dump" do
    state = Fancygrid::ViewState.new {}
  end
  
  describe "pagination scope" do
    it "should resolve pagination options" do
      state = Fancygrid::ViewState.new :pagination => { :page => 123, :per_page => 312 }
      state.pagination.should == { "page" => 123, "per_page" => 312 }
    end
    
    it "should resolve page value" do
      state = Fancygrid::ViewState.new :pagination => { :page => 123 }
      state.pagination_page.should be 123
    end
    
    it "should return fallback page value" do
      state = Fancygrid::ViewState.new :pagination => { }
      state.pagination_page(312).should be 312
    end
    
    it "should resolve per page value" do
      state = Fancygrid::ViewState.new :pagination => { :per_page => 123 }
      state.pagination_per_page.should be 123
    end
    
    it "should return fallback per page value" do
      state = Fancygrid::ViewState.new :pagination => { }
      state.pagination_per_page(312).should be 312
    end
  end
  
  describe "order scope" do
    it "should resolve order options" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b", :direction => "asc" }
      state.order.should == { "identifier" => "a.b", "direction" => "asc" }
    end
    
    it "should resolve order table" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b", :direction => "c" }
      state.order_table.should == "a"
    end
    
    it "should resolve order column" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b", :direction => "c" }
      state.order_column.should == "b"
    end
    
    it "should resolve order direction" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b", :direction => "desc" }
      state.order_direction.should == "desc"
    end
    
    it "ordered? should return true if all order options are set" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b", :direction => "desc" }
      state.ordered?.should be true
    end
    
    it "ordered? should return false if identifier option is missing" do
      state = Fancygrid::ViewState.new :order => { :direction => "c" }
      state.ordered?.should be false
    end
    
    it "ordered? should return false if direction option is missing" do
      state = Fancygrid::ViewState.new :order => { :identifier => "a.b" }
      state.ordered?.should be false
    end
  end

end