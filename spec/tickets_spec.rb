require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Ticketmaster::Provider::Mingle::Ticket" do
  before(:all) do
    headers = {'Authorization' => 'Basic Y29yZWQ6MTIzNDU2', 'Accept' => 'application/xml'}
    headers_post_put = {'Authorization' => 'Basic Y29yZWQ6MTIzNDU2', 'Content-Type' => 'application/xml'}
    @project_id = 'test-project'
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/projects.xml', headers, fixture_for('projects'), 200
      mock.get '/projects/test-project/cards/1.xml', headers, fixture_for('projects/test-project/cards/1'), 200
      mock.get '/cards.xml', headers, fixture_for('cards'), 200
      mock.get '/cards/1.xml', headers, fixture_for('cards/1'), 200
      mock.put '/cards/1.xml', headers_post_put, '', 200
      mock.post '/cards.xml', headers_post_put, '', 200
    end
  end

  before(:each) do 
    @ticketmaster = TicketMaster.new(:mingle, {:server => 'myserver.com', :username => 'anymoto', :password => '000000'})
    @project = @ticketmaster.project(@project_id)
    @klass = TicketMaster::Provider::Mingle::Ticket
  end

  it "should be able to load all tickets" do 
    @project.tickets.should be_an_instance_of(Array)
    @project.tickets.first.should be_an_instance_of(@klass)
  end

  it "should be able to load all tickets based on an array of id's" do
    @tickets = @project.tickets([1])
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.title.should == 'test-card'
  end

  it "should be able to load all tickets based on attributes" do
    @tickets = @project.tickets(:id => 1)
    @tickets.should be_an_instance_of(Array)
    @tickets.first.should be_an_instance_of(@klass)
    @tickets.first.title.should == 'test-card'
  end

  it "should return the ticket class" do
    @project.ticket.should == @klass
  end

  it "should be able to load a single ticket" do
    @ticket = @project.ticket(1)
    @ticket.should be_an_instance_of(@klass)
    @ticket.title.should == 'test-card'
  end

  it "shoule be able to load a single ticket based on attributes" do
    @ticket = @project.ticket(:id => 1)
    @ticket.should be_an_instance_of(@klass)
    @ticket.title.should == 'test-card'
  end

  it "should be able to update and save a ticket" do 
    @ticket = @project.ticket(1)
    @ticket.description = 'New card description'
    @ticket.save.should == true
  end

  it "should be able to create a ticket" do 
    @ticket = @project.ticket!(:subject => 'Ticket #12', :description => 'Body')
    @ticket.should be_an_instance_of(@klass)
  end

end
