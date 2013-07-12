# step definitions describing creating and manipulating client objects

Given /^the hostname (\S+)$/ do |hostname|
  @hostname = hostname
end

Given /^the port (-?\d+)$/ do |port|
  @port = port.to_i
end

Given /^a MongoDB instance has been launched on host (\S+) at port (\d+)$/ do |host, port|
  # do nothing; assume there already is one
  # TODO actually do something sane here
end

Given /^the database name (\S+)$/ do |dbname|
  @dbname = dbname
end


When /^I request a connection to MongoDB with that hostname$/ do
  @client = Mongo::Client.new(@hostname, {:timeout => 1})
end

When /^I request a connection to MongoDB with that hostname and port$/ do
  @client = Mongo::Client.new(@hostname, {:port => @port, :timeout => 1})
end

When /^I ask the client for that database$/ do
  @db = @client[@dbname]
end


Then /^I will receive a connected client to the MongoDB instance running on host (\S+) at port (\d+)$/ do |host, port|
  @client.nil?.should == false
  @client.class.should == Mongo::Client
  @client.error.nil?.should == true
  @client.valid?.should == true
  @client.hostname.should == host
  @client.port.should == port.to_i
end

Then /^I will receive an error message stating that the connection failed$/ do
  @client.nil?.should == false
  @client.class.should == Mongo::Client
  @client.error.should == "Unable to connect to #{@hostname}:#{@port}."
end

Then /^I will not receive a connected client$/ do
  @client.valid?.should == false
end

Then /^I will receive a valid database corresponding to the database (\S+) on that client$/ do |dbname|
  @db.nil?.should == false
  @db.class.should == Mongo::Client::Database
  @db.error.nil?.should == true
  @db.valid?.should == true
  @db.name.should == dbname
  @db.is_on_client?(@client).should == true
end

Then /^I will receive an error message stating that the client is not connected$/ do
  @db.nil?.should == false
  @db.class.should == Mongo::Client::Database
  @db.error.should == "Failed to get database #{@dbname} because invalid client was given."
end

Then /^I will not receive a valid database$/ do
  @db.valid?.should == false
end