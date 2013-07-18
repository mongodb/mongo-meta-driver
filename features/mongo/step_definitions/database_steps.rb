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

# TODO: maybe split this up?
# Perform a CRUD operation. See below for steps describing these ops
# and their options
When /^I perform this (\S+)(?: operation)?(?: on the collection)?$/ do |which_op|
  case which_op
    when 'insert'
      @coll.insert(@insert_docs, @insert_options)
    when 'query'
      # TODO: these won't be needed eventually
      @query_skip_count ||= 0
      @query_return_count ||= 0
      @query_result =
        @coll.find(@query_doc, @query_field_doc, @query_skip_count, @query_return_count, @query_options)
    when 'update'
      @coll.update(@update_select_doc, @update_spec_doc, @update_options)
    when 'delete'
      @coll.remove(@delete_doc, @delete_options)
  end
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

# compensate for the fact that the object will have an unpredictable ID
Then /^the collection should contain only (the document .*)$/ do |doc|
  result = @coll.find.documents.map do |result_doc|
    result_doc.silent_delete '_id'
  end
  p result.class
  result.should_be_permutation_of [doc]
end

Then /^the collection should contain only the documents:$/ do |docs|
  result = @coll.find.documents.map do |result_doc|
    result_doc.silent_delete '_id'
  end
  result.should_be_permutation_of docs
end

Then /^the collection should not contain (the document .*)$/ do |doc|
  # grab everything from db, check all of them
  @coll.find.documents.all? do |queried_doc|
    queried_doc.silent_delete('_id').should_not == doc
  end
end

Then /^I should receive the documents:$/ do |docs|
  result = @query_result.documents.map do |result_doc|
    result_doc.silent_delete '_id'
  end
  result.should_be_permutation_of docs
end

#
# insert-related steps
Given /^I want to insert (the document .*)$/ do |doc|
  @insert_docs = [doc]
  @insert_options ||= {}
end

Given /^I want to insert the documents:$/ do |docs|
  @insert_docs = docs
  @insert_options ||= {}
end

# options; to be called after one of the above

#
# query-related steps
Given /^I want find documents matching (the document .*)$/ do |doc|
  @query_doc = doc
  @query_options ||= {}
end

Given /^I want to project only the fields of (the document .*)$/ do |doc|
  @query_field_doc = doc
  @query_options ||= {}
end

# options; to be called after one of the above
# Given /^$/

#
# update-related steps
Given /^I want to update documents selected by (the document .*)$/ do |doc|
  @update_select_doc = doc
  @update_options ||= {}
end

Given /^I want to perform the update specified by (the document .*)$/ do |doc|
  @update_spec_doc = doc
  @update_options ||= {}
end

# options; to be called after one of the above

#
# delete-related steps
# declares you're doing a delete. do this one before specifying options
Given /^I want to delete documents according to (the document .*)$/ do |doc|
  @delete_doc = doc
  @delete_options ||= {}
end

# options; to be called after one of the above