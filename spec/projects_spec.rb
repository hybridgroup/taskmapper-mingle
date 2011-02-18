require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Mingle::Project" do
  before(:all) do
    headers = {'Authorization' => 'Basic OjAwMDAwMA==', 'Accept' => 'application/xml'}
    headers_post = {'Authorization' => 'Basic OjAwMDAwMA==', 'Content-Type' => 'application/xml'}
    @identifier = 'test_project'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/api/v2/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/api/v2/projects/test_project.xml', headers, fixture_for('projects/test_project'), 200
      #mock.get '/api/v2/projects/dumb.xml', headers, fixture_for('projects/dumb'), 200
      mock.post '/api/v2/projects.xml', headers_post, '', 201#, 'Location' => '/projects/dumb'
    end
  end

  before(:each) do 
    @ticketmaster = TicketMaster.new(:mingle, {:server => 'myserver.com', :username => 'anymoto', :password => '000000'})
    @klass = TicketMaster::Provider::Mingle::Project
  end

  it "should be able to load all projects" do 
    @ticketmaster.projects.should be_an_instance_of(Array)
    @ticketmaster.projects.first.should be_an_instance_of(@klass)
  end

  it "should be able to load projects from an array of id's" do 
    @projects = @ticketmaster.projects([@identifier])
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.identifier.should == @identifier
  end

  it "should be able to load all projects from attributes" do 
    @projects = @ticketmaster.projects(:identifier => 'test_project')
    @projects.should be_an_instance_of(Array)
    @projects.first.should be_an_instance_of(@klass)
    @projects.first.identifier.should == 'test_project'
  end

  it "should be able to find a project" do 
    @ticketmaster.project.should == @klass
    @ticketmaster.project.find(@identifier).should be_an_instance_of(@klass)
  end

  it "should be able to find a project by identifier" do 
    @ticketmaster.project(@identifier).should be_an_instance_of(@klass)
    @ticketmaster.project(@identifier).identifier.should == @identifier
  end

  it "should be able to create a new project" do 
    @project = @ticketmaster.project!(:name => 'Another project', :identifier => 'dumb', :description => 'This is a another project').should be_an_instance_of(@klass)
  end


end
