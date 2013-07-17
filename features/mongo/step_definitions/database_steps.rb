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
end

Given /^the collection object for collection (\S+)$/ do |collname|
  @collname = collname
  @coll = @db[@collname]
end

Given /^the collection has been emptied$/ do
  @coll.remove
end

Given /^the collection contains only (the document .*)$/ do |doc|
  @coll.remove
  @coll.insert doc
end

Given /^the collection contains only the documents:$/ do |docs|
  @coll.remove
  @coll.insert docs
end


When /^I ask the database for that collection$/ do
 @coll = @db[@collname]
end

When /^I ask the collection to insert (the document .*)$/ do |doc|
  @coll.insert doc
end

When /^I ask the collection to delete all documents matching (the document .*)$/ do |doc|
  @coll.remove doc
end

When /^I query the collection using (the document .*)$/ do |doc|
  @query_result = @coll.find doc
end


Then /^I will have a valid collection object corresponding to the collection (\S+) on that database$/ do |collname|
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
  @coll.find.documents.should == [doc]
end

Then /^the collection should not contain (the document .*)$/ do |doc|
  similar_docs = @coll.find
  res = similar_docs.all? do |similar_doc|
    similar_doc.should_not == doc
  end
end

Then /^I should receive the documents:$/ do |docs|
  @query_result.documents.should == docs
end