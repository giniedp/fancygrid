require "spec_helper"

describe Fancygrid::QueryGenerator do
  it "should be an instance of Fancygrid::Query" do
    defaults = {}
    generator = Fancygrid::QueryGenerator.new(defaults)
    generator.should be_an_instance_of Fancygrid::QueryGenerator
  end

  it "should evaluate" do
    @query = {
      :conditions => {
        :tickets => {
          :title => {
            :operator => "is_equal_to",
            :value => "a string"
          }
        },
        :projects => {
          :title => {
            :operator => "is_equal_to",
            :value => "a string"
          }
        }
      },
      :order => 'projects.title ASC',
      :pagination => {
        :page => 1,
        :per_page => 5
      }
    }
    @generator = Fancygrid::QueryGenerator.new
    @generator.evaluate(@query).should be_a(Hash)
  end
  
  
  describe "evaluating select" do
    before(:each) do
      leafs = [stub(:select_name => 'tickets.title'), stub(:select_name => 'projects.title')]
      defaults = {
        :select => leafs.map{|l| l.select_name}
      }
      @generator = Fancygrid::QueryGenerator.new(defaults)
    end
    
    it "should evaluate" do
      @generator.evaluate[:select].should == ["tickets.title", "projects.title"]
    end
    
    describe "overriding select" do
      it "should evaluate to * overriding with *" do
        @generator.evaluate(:select => "*")[:select].should == "*"
      end
      
      it "should evaluate with selects" do
        @generator.evaluate(:select => "tickets.price")[:select].should == ["tickets.price", "tickets.title", "projects.title"]
      end
    end
  end
  
  describe "evaluating where" do
    before(:each) do
      @query = {
        :conditions => {
          :tickets => {
            :title => {
              :operator => "is_equal_to",
              :value => "a string"
            }
          }
        }
      }
      @generator = Fancygrid::QueryGenerator.new
    end
    
    it "should evaluate" do
      @generator.evaluate(@query)[:conditions].should == ["tickets.title = ?", "a string"]
    end
    
    it "should join conditions with OR by default" do
      new_condition = {
        :projects => {
          :title => {
            :operator => "is_equal_to",
            :value => "a project"
          }
        }
      }
      @query[:conditions].merge!(new_condition)
      @generator.evaluate(@query)[:conditions].should == ["projects.title = ? OR tickets.title = ?", "a project", "a string"]
    end
    
    it "should join conditions with AND" do
      new_condition = {
        :projects => {
          :title => {
            :operator => "is_equal_to",
            :value => "a project"
          }
        }
      }
      @query[:conditions].merge!(new_condition)
      @query[:all] = "1"
      @generator.evaluate(@query)[:conditions].should == ["projects.title = ? AND tickets.title = ?", "a project", "a string"]
    end
  end
  
  describe "evaluating pagination" do
    before(:each) do
      @query = {
        :pagination => {
          :page => 2, # pages starts by 0
          :per_page => 5
        }
      }
      @generator = Fancygrid::QueryGenerator.new
    end
            
    it "should evaluate limit" do
      @generator.evaluate(@query)[:limit].should == 5
    end
    it "should evaluate offset" do
      @generator.evaluate(@query)[:offset].should == 10
    end
  end
  
  describe "evaluation order" do
    before(:each) do
      defaults = {
        :order => "title DESC"
      }
      @generator = Fancygrid::QueryGenerator.new(defaults)
    end
        
    it "should evaluate order" do
      @generator.evaluate[:order].should == "title DESC"
    end
    
    describe "overriding order" do
      it "should override order" do
        query = {
          :order => 'title ASC'
        }
        @generator.evaluate(query)[:order].should == "title ASC"
      end
    end
  end
end