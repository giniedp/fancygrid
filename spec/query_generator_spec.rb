require "spec_helper"

describe Fancygrid::QueryGenerator do
  
  def build_generator
    Fancygrid::QueryGenerator.new({
      :pagination => {
        :page => 5,
        :per_page => 10
      },
      :order => {
        :column => "users.name",
        :order => "asc"
      },
      :operator => :all,
      :conditions => {
        :table_name => { 
          :a => { :operator => :equal, :value => "value_a" },
          :b => { :operator => :not_equal, :value => "value_b" }
        }
      }
    })
  end
  
  def build_generator_with_array
    Fancygrid::QueryGenerator.new({
      :pagination => {
        :page => 5,
        :per_page => 10
      },
      :order => {
        :column => "users.name",
        :order => "asc"
      },
      :operator => :all,
      :conditions => {
        :table_name => {
          :a => [
            { :operator => :equal, :value => "value_a" },
            { :operator => :equal, :value => "value_a2" }
          ],
          :b => { :operator => :not_equal, :value => "value_b" }
        }
      }
    })
  end
  
  def build_generator_with_pseudo_array
    Fancygrid::QueryGenerator.new({
      :pagination => {
        :page => 5,
        :per_page => 10
      },
      :order => {
        :column => "users.name",
        :order => "asc"
      },
      :operator => :all,
      :conditions => {
        :table_name => {
          :a => {
            "0" => { :operator => :equal, :value => "value_a" },
            "1" => { :operator => :equal, :value => "value_a2" },
          },
          :b => { :operator => :not_equal, :value => "value_b" }
        }
      }
    })
  end
  
  it "should be an instance of Fancygrid::Query" do
    generator = build_generator
    generator.should be_an_instance_of Fancygrid::QueryGenerator
  end

  it "should initialize with a valid limit" do
    build_generator.limit.should be(10)
  end
  
  it "should initialize with a valid offset" do
    build_generator.offset.should be(50)
  end
  
  it "should initialize with a valid order" do 
    build_generator.order.should == "users.name ASC"
  end
  
  it "should initialize with valid conditions" do
    build_generator.conditions.should == ["( table_name.a = (?) ) AND ( table_name.b != (?) )", "value_a", "value_b"]
  end
  
  it "should append conditions" do
    generator = build_generator
    generator.conditions(["roles.name = ?", "foo"])
    generator.conditions.should == ["(( table_name.a = (?) ) AND ( table_name.b != (?) )) AND (roles.name = ?)", "value_a", "value_b", "foo"]
  end
  
  it "should override order" do
    generator = build_generator
    generator.order("order")
    generator.order.should == "order"
  end
  
  it "should override group" do
    generator = build_generator
    generator.group("group")
    generator.group.should == "group"
  end
  
  it "should override having" do
    generator = build_generator
    generator.having("having")
    generator.having.should == "having"
  end
  
  it "should override limit" do
    generator = build_generator
    generator.limit("limit")
    generator.limit.should == "limit"
  end
  
  it "should override offset" do
    generator = build_generator
    generator.offset("offset")
    generator.offset.should == "offset"
  end
  
  it "should override joins" do
    generator = build_generator
    generator.joins("joins")
    generator.joins.should == "joins"
  end
  
  it "should override include" do
    generator = build_generator
    generator.include("include")
    generator.include.should == "include"
  end
  
  it "should append select" do
    generator = build_generator
    generator.select("select")
    generator.select.should == ["select"]
  end
  
  it "should override and keep select with star '*'" do
    generator = build_generator
    generator.select("select")
    generator.select.should == ["select"]
    generator.select("*")
    generator.select.should == ["*"]
    generator.select("select")
    generator.select.should == ["*"]
  end
  
  it "should override from" do
    generator = build_generator
    generator.from("from")
    generator.from.should == "from"
  end
  
  it "should override readonly" do
    generator = build_generator
    generator.readonly("readonly")
    generator.readonly.should == "readonly"
  end
  
  it "should override lock" do
    generator = build_generator
    generator.lock("lock")
    generator.lock.should == "lock"
  end
  
  it "should be backward compatible with old fancygrid" do
    query = Fancygrid::QueryGenerator.new({
      :pagination => {
        :page => 5,
        :per_page => 10
      },
      :order => {
        :column => "users.name",
        :order => "asc"
      },
      :operator => :all,
      :conditions => {
        :events => {
          :name => "a",
          :id => "b"
        }
      }
    })
    query.conditions.should == ["( events.name LIKE (?) ) AND ( events.id LIKE (?) )", "%a%", "%b%"]
  end
  
  it "should generate query using array" do
    build_generator_with_array.conditions.should == ["( table_name.a = (?) ) AND ( table_name.a = (?) ) AND ( table_name.b != (?) )", "value_a", "value_a2", "value_b"]
  end
  
  it "should generate query using pseudo array" do
    build_generator_with_pseudo_array.conditions.should == ["( table_name.a = (?) ) AND ( table_name.a = (?) ) AND ( table_name.b != (?) )", "value_a", "value_a2", "value_b"]
  end
  
  #it "should evaluate" do
  #  @query = {
  #    :conditions => {
  #      :tickets => {
  #        :title => {
  #          :operator => "is_equal_to",
  #          :value => "a string"
  #        }
  #      },
  #      :projects => {
  #        :title => {
  #          :operator => "is_equal_to",
  #          :value => "a string"
  #        }
  #      }
  #    },
  #    :order => 'projects.title ASC',
  #    :pagination => {
  #      :page => 1,
  #      :per_page => 5
  #    }
  #  }
  #  @generator = Fancygrid::QueryGenerator.new
  #  @generator.evaluate(@query).should be_a(Hash)
  #end
  #
  #
  #describe "evaluating select" do
  #  before(:each) do
  #    leafs = [stub(:select_name => 'tickets.title'), stub(:select_name => 'projects.title')]
  #    defaults = {
  #      :select => leafs.map{|l| l.select_name}
  #    }
  #    @generator = Fancygrid::QueryGenerator.new(defaults)
  #  end
  #  
  #  it "should evaluate" do
  #    @generator.evaluate[:select].should == ["tickets.title", "projects.title"]
  #  end
  #  
  #  describe "overriding select" do
  #    it "should evaluate to * overriding with *" do
  #      @generator.evaluate(:select => "*")[:select].should == "*"
  #    end
  #    
  #    it "should evaluate with selects" do
  #      @generator.evaluate(:select => "tickets.price")[:select].should == ["tickets.price", "tickets.title", "projects.title"]
  #    end
  #  end
  #end
  #
  #describe "evaluating where" do
  #  before(:each) do
  #    @query = {
  #      :conditions => {
  #        :tickets => {
  #          :title => {
  #            :operator => "is_equal_to",
  #            :value => "a string"
  #          }
  #        }
  #      }
  #    }
  #    @generator = Fancygrid::QueryGenerator.new
  #  end
  #  
  #  it "should evaluate new conditions syntax" do
  #    @generator.evaluate(@query)[:conditions].should == ["tickets.title = ?", "a string"]
  #  end
  #  
  #  it "should evaluate old conditions syntax" do
  #    query = {
  #      :conditions => {
  #        :tickets => {
  #          :title => "a string"
  #        }
  #      }
  #    }
  #    @generator.evaluate(query)[:conditions].should == ["tickets.title LIKE ?", "%a string%"]
  #  end                       
  #  
  #  it "should append default conditions with params conditions" do
  #    defaults = {:conditions => ['tickets.open = ?', 1]}
  #    @generator = Fancygrid::QueryGenerator.new(defaults)
  #    @generator.evaluate(@query)[:conditions].should == ["(tickets.open = ?) AND (tickets.title = ?)", 1, "a string"]
  #  end
  #      
  #  it "should join conditions with OR by default" do
  #    new_condition = {
  #      :projects => {
  #        :title => {
  #          :operator => "is_equal_to",
  #          :value => "a project"
  #        }
  #      }
  #    }
  #    @query[:conditions].merge!(new_condition)
  #    @generator.evaluate(@query)[:conditions].should == ["projects.title = ? OR tickets.title = ?", "a project", "a string"]
  #  end
  #  
  #  it "should join conditions with AND" do
  #    new_condition = {
  #      :projects => {
  #        :title => {
  #          :operator => "is_equal_to",
  #          :value => "a project"
  #        }
  #      }
  #    }
  #    @query[:conditions].merge!(new_condition)
  #    @query[:all] = "1"
  #    @generator.evaluate(@query)[:conditions].should == ["projects.title = ? AND tickets.title = ?", "a project", "a string"]
  #  end
  #end
  #
  #describe "evaluating pagination" do
  #  before(:each) do
  #    @query = {
  #      :pagination => {
  #        :page => 2, # pages starts by 0
  #        :per_page => 5
  #      }
  #    }
  #    @generator = Fancygrid::QueryGenerator.new
  #  end
  #          
  #  it "should evaluate limit" do
  #    @generator.evaluate(@query)[:limit].should == 5
  #  end
  #  it "should evaluate offset" do
  #    @generator.evaluate(@query)[:offset].should == 10
  #  end
  #end
  #
  #describe "evaluation order" do
  #  before(:each) do
  #    defaults = {
  #      :order => "title DESC"
  #    }
  #    @generator = Fancygrid::QueryGenerator.new(defaults)
  #  end
  #      
  #  it "should evaluate order" do
  #    @generator.evaluate[:order].should == "title DESC"
  #  end
  #  
  #  describe "overriding order" do
  #    it "should override order" do
  #      query = {
  #        :order => 'title ASC'
  #      }
  #      @generator.evaluate(query)[:order].should == "title ASC"
  #    end
  #  end
  #end
end