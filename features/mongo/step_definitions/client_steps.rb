# step definitions describing creating and manipulating client objects

Given /^the hostname (\S+)$/ do |hostname|
  @hostname = hostname
end

Given /^the port (-?\d+)$/ do |port|
  @port = port
end

Given /^a MongoDB instance has been launched on host (\S+) at port (\d+)$/ do |host, port|
  # do nothing; assume there already is one
  # TODO actually do something sane here
end

Given /^there is no MongoDB instance running on host (\S+) at port (\d+)$/ do
  @remote_host = nil
  @remote_port = nil
end

When /^I request a connection to MongoDB with that hostname$/ do
  @client = Mongo::Client.new(@hostname)
end

When /^I request a connection to MongoDB with that hostname and port$/ do
  @client = Mongo::Client.new(@hostname, @port)
end

Then /^I will receive a connected client to the MongoDB instance running on host (\S+) at port (\d+)$/ do |host, port|
  @client.nil?.should == false
  @client.connected?.should == true
  @client.hostname.should == host
  @client.port.should == port
end

Then /^I will receive an error message stating that the connection failed$/ do

end

Then /^I will receive an error message stating that hostname (\S+) is invalid$/ do
  
end

Then /^I will receive an error message stating that port (\d+) is invalid$/ do
  pending
end

Then /^I will not receive a client$/ do
  @client.should == nil
end
