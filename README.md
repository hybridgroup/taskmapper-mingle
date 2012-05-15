# taskmapper-mingle

This is a provider for [taskmapper](http://ticketrb.com). It provides interoperability with [Mingle](http://www.thoughtworks-studios.com/mingle-agile-project-management/) and it's issue tracking system through the taskmapper gem.

# Usage and Examples

First we have to instantiate a new taskmapper instance, your Mingle installation should have api access enable:

    mingle = TaskMapper.new(:mingle, {:server => 'myserver', :username=> 'foo', :password => 'bar'})

If you do not pass in the server name, username and password, you won't get any information.

Also you have to enable basic authentication, set the basic_authentication_enabled configuration option to true in the Mingle data directory/config/auth_config.yml file, where Mingle data directory is the path to the Mingle data directory:

    basic_authentication_enabled: true

## Finding Projects

You can find your own projects by doing:

    projects = mingle.projects # Will return all your projects
    projects = mingle.projects(["project1", "project2"]) # You must use your projects identifier 
    project = mingle.project("your_project") # Also use project identifier in here

## Creating a project

    project = mingle.project!(:name => "New Project", :identifier => "new_project", :description => "This is a new project")
	
## Finding Tickets(Cards)

    tickets = project.tickets # All tickets
    ticket = project.ticket(<ticket_number>)

## Open Tickets

	ticket = project.ticket!({:name => "New ticket", :description=> "Body for the very new ticket"})


## Finding comments
      
  comments = project.ticket.comments 

## Creating a comment

  comment = ticket.comment!(:content => 'New comment created.')

## Requirements

* rubygems (obviously)
* taskmapper gem (latest version preferred)
* jeweler gem (only if you want to repackage and develop)
* Mingle

The taskmapper gem should automatically be installed during the installation of this gem if it is not already installed.

## Other Notes

Since this and the taskmapper gem is still primarily a work-in-progress, minor changes may be incompatible with previous versions. Please be careful about using and updating this gem in production.

If you see or find any issues, feel free to open up an issue report.


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so we don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself so we can ignore when I pull)
* Send us a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2011 The Hybrid Group. See LICENSE for details.


