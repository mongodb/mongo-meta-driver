# step definitions describing creating and manipulating client objects

Given /^a valid hostname (\S+)$/ do |hostname|
  @hostname = hostname
end

Given /^a valid port (\d+)$/ do
  pending
end

Given /^a MongoDB instance has been launched on host (\S+) at port (\d+)$/ do |host, port|
  @remote_host = host
  @remote_port = port
end

Given /^there is no MongoDB instance running on host (\S+) at port (\d+)$/ do
  @remote_host = nil
  @remote_port = nil
end

When /^I request a connection to MongoDB on host (\S+)(?: at port (\d+))$/ do
  @client = Mongo::Client.new(host, port)
end

Then /^I will receive a connected client to the MongoDB instance on host (\S+) at port (\d+)$/ do
  @client.connected?.should == true
end

Then /^I will receive an error message stating that hostname (\S+) is invalid$/ do
  
end

Then /^I will receive an error message stating that port (\d+) is invalid$/ do
  pending
end

Then /^I will not receive a client$/ do
  pending
end
