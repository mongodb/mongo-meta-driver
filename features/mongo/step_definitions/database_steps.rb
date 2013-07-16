# step definitions describing manipulating database and collection objects
# ref_client & co. are objects from a known-good reference implementation (Ruby driver, in this case)

Given /^I have successfully obtained a database object connected to a database on a running instance of MongoDB$/ do
  @dbname = 'mydb'
  @client = Mongo::Client.new('127.0.0.1', {:timeout => 1})
  @client.valid?.should == true
  @db = @client[@dbname]
  @db.valid?.should == true
end

Given /^the collection (\S+)$/ do |collname|
  @collname = collname

  # set up reference connection
  @ref_client = Mongo::MongoClient.new('localhost', 27017)
  @ref_coll = @ref_client[@dbname][@collname]
end

Given /^the collection has been emptied$/ do
  @ref_coll.remove
end

Given /^the collection contains (the document .*)$/ do |doc|
  @doc_in_collection = doc
  pending
  # actually do the insert
end

Given /^the collection contains the documents:$/ do |docs_as_list_of_hash|
  pending
end


When /^I ask the database for that collection$/ do
 @coll = @db[@collname]
end

When /^I ask the collection to insert (the document .*)$/ do |doc|
  @doc_to_insert = JSON[doc]
  pending
end

When /^I ask the collection to delete all documents matching (the document .*)$/ do |doc|
  @doc_to_delete = doc
  pending
end

When /^I query the collection using (the document .*)$/ do |doc|
  pending
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

Then /^the collection should contain only (the document .*)$/ do |doc|
  @doc_in_collection = JSON[doc]
  pending
end

Then /^the collection should not contain (the document .*)$/ do |doc|
  pending
end

Then /^I should receive the documents:$/ do |docs_as_list_of_hash|
  pending
end