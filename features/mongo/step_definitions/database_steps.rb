# step definitions describing manipulating database objects

Given /^I have successfully obtained a database object connected to a database on a running instance of MongoDB$/ do
  @client = Mongo::Client.new('127.0.0.1', {:timeout => 1})
  @client.valid?.should == true
  @db = @client['mydb']
  @db.valid?.should == true
end

Given /^the collection (\S+)$/ do |collname|
  @collname = collname
end


When /^I ask the database for that collection$/ do
 @coll = @db[@collname]
end


Then /^I will receive a valid collection object corresponding to the collection (\S+) on that database$/ do |collname|
  @coll.nil?.should == false
  @coll.class.should == Mongo::Client::Collection
  @coll.error.nil?.should == true
  @coll.valid?.should == true
  @coll.name.should == collname
  @coll.is_on_db(@db).should == true
end

Then /^I will not receive a valid collection$/ do
  @coll.valid?.should == false
end