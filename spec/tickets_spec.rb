require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Provider::Mingle::Ticket" do
  before(:all) do
    headers = {'Authorization' => 'Basic OjAwMDAwMA==', 'Accept' => 'application/xml'}
    headers_post_put = {'Authorization' => 'Basic OjAwMDAwMA==', 'Content-Type' => 'application/xml'}
    @identifier = 'test_project'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/api/v2/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/api/v2/projects/test_project.xml', headers, fixture_for('projects/test_project'), 200
      mock.get '/api/v2/projects/test_project/cards/42.xml', headers, fixture_for('cards/42'), 200
      mock.get '/api/v2/projects/test_project/cards.xml', headers, fixture_for('cards'), 200
      mock.get '/api/v2/projects/test_project/cards/42.xml', headers, fixture_for('cards/42'), 200
      mock.put '/api/v2/projects/test_project/cards/42.xml?card[number]=42&card[name]=Ticket%201&card[created_on]=Wed%20Oct%2014%2009:14:54%20UTC%202009&card[id]=0&card[modified_on]=Wed%20Oct%2014%2009:14:54%20UTC%202009&card[description]=New%20card%20description', headers_post_put, '', 200
      mock.post '/api/v2/projects/test_project/cards.xml?card[title]=Ticket%20%2312&card[description]=Body', headers_post_put, '', 200
    end
  end

  before(:each) do 
    @taskmapper = TaskMapper.new(:mingle, {:server => 'myserver.com', :username => 'anymoto', :password => '000000'})
    @project = @taskmapper.project(@identifier)
    @klass = TaskMapper::Provider::Mingle::Ticket
  end

  it "should be able to load all tickets" do 
    @project.tickets.should be_an_instance_of(Array)
    @project.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on an array of id's" do
    @tickets = @project.tickets([42])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.name.should == 'Ticket 1'
  end

  it "should be able to load all tickets based on attributes" do
    @tickets = @project.tickets(:number => 42)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.name.should == 'Ticket 1'
  end

  it "should return the ticket class" do
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    @ticket = @project.ticket(42)
    @ticket.should be_an_instance_of(@klass)
    @ticket.name.should == 'Ticket 1'
  end

  it "shoule be able to load a single ticket based on attributes" do
    @ticket = @project.ticket(:number => 42)
    @ticket.should be_an_instance_of(@klass)
    @ticket.name.should == 'Ticket 1'
  end

  it "should be able to update and save a ticket" do 
    @ticket = @project.ticket(42)
    @ticket.description = 'New card description'
    @ticket.save.should == true
  end

  it "should be able to create a ticket" do 
    @ticket = @project.ticket!(:title => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
  end

end
