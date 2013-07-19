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
# Perform a CRUD operation.
# All of these options get set up in wire_steps.rb
When /^I perform this (\S+)(?: operation)?(?: on the collection)?$/ do |which_op|

  case which_op
    when 'insert'
      insert_options = hashify [:continue_on_error]
      @coll.insert(@docs_to_insert, insert_options)

    when 'query'
      query_options = hashify [:tailable_cursor, :slave_ok, :no_cursor_timeout, :await_data, :exhaust, :partial]
      @query_result =
        @coll.find(@query_doc, @return_select_doc, @num_skip_results, @num_return_results, query_options)

    when 'update'
      update_options = hashify [:upsert, :multi_update]
      @coll.update(@update_doc, @update_spec_doc, update_options)

    when 'delete'
      delete_options = hashify [:single_remove]
      @coll.remove(@delete_doc, delete_options)

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

Given /^I am performing an? (\S+)(?: operation)?$/ do |op_type|
  @which_op = op_type
end

# for the "Given" steps that "fill out" the command you're generating
# see wire_steps.rb