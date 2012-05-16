require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Provider::Mingle" do

  before(:all) do
    @taskmapper = TaskMapper.new(:mingle, {:server => 'myserver.com', :username => 'anymoto', :password => '000000'})
  end
  
  it "should be able to instantiate a new instance" do
    @taskmapper.should be_an_instance_of(TaskMapper)
    @taskmapper.should be_a_kind_of(TaskMapper::Provider::Mingle)
  end

  it "should return true for a valid authentication" do
    pendinZ
    @taskmapper.valid?.should be_true
  end
  
end
