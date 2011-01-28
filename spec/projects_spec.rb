require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Mingle::Project" do
  before(:all) do
    headers = {'Authorization' => 'Basic Y29yZWQ6MTIzNDU2', 'Accept' => 'application/xml'}
    headers_post_put = {'Authorization' => 'Basic Y29yZWQ6MTIzNDU2', 'Content-Type' => 'application/xml'}
    @project_id = 'test-project'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/projects/test-project.xml', headers, fixture_for('projects/test-project'), 200
      mock.put '/projects/new-project.xml', headers_post_put, '', 200
      mock.post '/projects.xml', headers_post_put, '', 200
    end
  end

  before(:each) do 
    @ticketmaster = TicketMaster.new(:mingle, {:server => 'mingle.server', :port => '8080', :username => 'anymoto', :password => '000000'})
    @klass = TicketMaster::Provider::Mingle::Project
  end

  it "should be able to load all projects" do 
    @ticketmaster.projects.should be_an_instance_of(Array)
    @ticketmaster.projects.first.should be_an_instance_of(@klass)
  end

  it "should be able to load projects from an array of id's" do 
    @projects = @ticketmaster.projects([@project_id])
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == @project_id
  end

  it "should be able to load all projects from attributes" do 
    @projects = @ticketmaster.projects(:id => 'test-project')
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.id.should == 'test-project'
  end

  it "should be able to find a project" do 
    @ticketmaster.project.should == @klass
    @ticketmaster.project.find(@project_id).should be_an_instance_of(@klass)
  end

  it "should be able to find a project by identifier" do 
    @ticketmaster.project(@project_id).should be_an_instance_of(@klass)
    @ticketmaster.project(@project_id).identifier.should == @project_id
  end

  it "should be able to update and save a project" do
    @project = @ticketmaster.project(@project_id)
    @project.update!(:name => 'New project name').should == true
  end

  it "should be able to create a new project" do 
    @project = @ticketmaster.project!(:name => 'New project', :description => 'This is a new project').should be_an_instance_of(@klass)
  end
end
