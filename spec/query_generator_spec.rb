require "spec_helper"

describe Fancygrid::QueryGenerator do
  it "should be an instance of Fancygrid::Query" do
    query = {}
    generator = Fancygrid::QueryGenerator.new(query)
    generator.should be_an_instance_of Fancygrid::QueryGenerator
  end
  
  describe "evaluating select" do
    before(:each) do
      query = {
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
        }
      }
      leafs = [stub(:select_name => 'tickets.title'), stub(:select_name => 'projects.title')]
      @generator = Fancygrid::QueryGenerator.new(query, leafs)
    end
    
    it "should evaluate" do
      @generator.select.should == ["tickets.title", "projects.title"]
    end
    
    describe "overriding select" do
      it "should evaluate to * overriding with *" do
        options = {
          :select => "*"
        }
        @generator.override(options)
        @generator.select.should == "*"
      end
      
      it "should evaluate with selects" do
        options = {
          :select => "tickets.price"
        }
        @generator.override(options)
        @generator.select.should == ["tickets.price", "tickets.title", "projects.title"]
        
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
    end
    
    it "should evaluate" do
      @generator = Fancygrid::QueryGenerator.new(@query)
      @generator.where.should == ["tickets.title = ?", "a string"]
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
      @generator = Fancygrid::QueryGenerator.new(@query)
      @generator.where.should == ["projects.title = ? OR tickets.title = ?", "a project", "a string"]
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
      @generator = Fancygrid::QueryGenerator.new(@query)
      @generator.where.should == ["projects.title = ? AND tickets.title = ?", "a project", "a string"]
    end
  end
  
  describe "evaluating pagination" do
    before(:each) do
      query = {
        :pagination => {
          :page => 2, # pages starts by 0
          :per_page => 5
        }
      }
      @generator = Fancygrid::QueryGenerator.new(query)
    end
    
    it "should have pagination" do
      @generator.should be_pagination
    end
        
    it "should evaluate limit" do
      @generator.limit.should == 5
    end
    it "should evaluate offset" do
      @generator.offset.should == 10
    end
  end
  
  describe "evaluation order" do
    before(:each) do
      query = {
        :order => "title DESC"
      }
      @generator = Fancygrid::QueryGenerator.new(query)
    end
    
    it "should have order" do
      @generator.should be_order
    end
    
    it "should evaluate order" do
      @generator.order.should == "title DESC"
    end
  end
  
  describe "evaluating" do
    before(:each) do
      query = {
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
      @generator = Fancygrid::QueryGenerator.new(query)
    end
    
    it "should evaluate" do
      pending
      puts @generator.evaluate.inspect
    end
  end
  
end