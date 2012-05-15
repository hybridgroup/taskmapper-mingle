require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TaskMapper::Provider::Mingle::Comment" do
  before(:all) do
    headers = {'Authorization' => 'Basic MDAwMDAwOg==', 'Accept' => 'application/xml'}
    headers_post = {'Authorization' => 'Basic MDAwMDAwOg==', 'Content-Type' => 'application/xml'}
    ActiveResource::HttpMock.respond_to do |mock|
      mock.get '/api/v2/projects/test_project.xml', headers, fixture_for('projects/test_project'), 200
      mock.get '/api/v2/projects/test_project/cards.xml', headers, fixture_for('cards'), 200
      mock.get '/api/v2/projects/test_project/cards/42.xml', headers, fixture_for('cards/42'), 200
      mock.get '/api/v2/projects/test_project/cards/42/comments.xml', headers, fixture_for('comments'), 200
      mock.post '/api/v2/projects/test_project/cards/42/comments.xml?comment[content]=New%20comment%20created.', headers_post, fixture_for('comments/create'), 200
    end
    @identifier = 'test_project'
    @number = 42
  end
  
  before(:each) do
    @taskmapper = TaskMapper.new(:mingle, {:name => 'anymoto', :login => '000000', :server => 'localhost:8080'})
    @project = @taskmapper.project(@identifier)
    @ticket = @project.ticket(@number)
    @ticket.identifier = @project.identifier
    @klass = TaskMapper::Provider::Mingle::Comment
  end
  
  it "should be able to load all comments" do
    @comments = @ticket.comments
    @comments.should be_an_instance_of(Array)
    @comments.first.should be_an_instance_of(@klass)
  end
  
  it "should return the class" do
    @ticket.comment.should == @klass
  end
  
  it "should be able to create a comment" do
    @comment = @ticket.comment!(:content => 'New comment created.')
    @comment.should be_an_instance_of(@klass)
  end
end
