# step definitions for wire protocol
Given /^my request will have an ID of (\d+)$/ do |id|
  @id = id.to_i
end

Given /^I am using the collection "(.*?)"$/ do |coll_name|
  @coll_name = coll_name
end

Given /^I am (generating an? \S+ message)$/ do |op_class|
  @msg_class = op_class
end

Given /^I am selecting fields to update by (the document .*)$/ do |doc|
  @update_select_doc = doc
end

Given /^I am selecting fields to return by (the document .*)$/ do |doc|
  @return_select_doc = doc
end

Given /^I am updating by (the document .*)$/ do |doc|
  @update_doc = doc
end

Given /^I am querying by (the document .*)$/ do |doc|
  @query_doc = doc
end

Given /^I am selecting documents to delete by (the document .*)$/ do |doc|
  @delete_doc = doc
end

Given /^I am requesting results for the cursor with id (\d+)$/ do |cur_id|
  @cursor_to_get_more = cur_id.to_i
end

Given /^I am inserting the documents:$/ do |table|
  # table is a Cucumber::Ast::Table
  @docs_to_insert = table.rows.map do |row|
    JSON[row.first]
  end
end

Given /^I am deleting the cursors with ids:$/ do |table|
  # table is a Cucumber::Ast::Table
  @cursors_to_delete = table.rows.map do |row|
    row.first.to_i
  end
end

# non-binary options
Given /^I am skipping (\d+) results$/ do |num|
  @num_skip_results = num.to_i
end

Given /^I am returning (\d+) results$/ do |num|
  @num_return_results = num.to_i
end

Given /^MongoDB has responded with the OP_REPLY message (\S+)$/ do |wire|
  @wire = [wire].pack('H*')
end

# actually, message header generation. for ensuring randomness of IDs, headers are all we need
Given /^I have generated a message$/ do
  @header_1 = Mongo::Wire::MessageHeader.new
end

# binary flags below
# the weird or-ing stuff has to do with needing to tolerate the difference
# between human-generated and table-generated scenarios
# (the latter may have an extra space)
Given /^(I am (?:not | |)doing an upsert)$/ do |bool|
  @upsert = bool
end

Given /^(I am (?:not | |)doing a multi update)$/ do |bool|
  @multi_update = bool
end

Given /^(I am (?:not | |)doing a continue on error)$/ do |bool|
  @continue_on_error = bool
end

Given /^(I am (?:not | |)doing a tailable cursor query)$/ do |bool|
  @tailable_cursor = bool
end

Given /^(I am (?:not | |)permitting querying of a replica slave)$/ do |bool|
  @slave_ok = bool
end

Given /^(I am (?:not | |)permitting idle cursors to persist)$/ do |bool|
  @no_cursor_timeout = bool
end

Given /^(I am (?:not | |)permitting cursors to block and wait for more data)$/ do |bool|
  @await_data = bool
end

Given /^(I am (?:not | |)pulling all queried data at once)$/ do |bool|
  @exhaust = bool
end

Given /^(I am (?:not | |)permitting partial results if a shard is down)$/ do |bool|
  @partial = bool
end

Given /^(I am (?:not | |)permitting removal of multiple documents)$/ do |bool|
  @single_remove = (not bool)
end


When /^I generate the wire protocol message for this request$/ do
  @msg = @msg_class.new
  @msg.get_header.request_id(@id)

  # hack to make the case statement comparisons work
  case [@msg_class]
  when [Mongo::Wire::RequestMessage::Update]
    flags = Mongo::Wire::RequestMessage::Update::RequestFlags.new
    flags.upsert(@upsert).multi_update(@multi_update)
    @msg.flags(flags)
        .full_collection_name(@coll_name).selector(@update_select_doc).update(@update_doc)

  when [Mongo::Wire::RequestMessage::Insert]
    flags = Mongo::Wire::RequestMessage::Insert::RequestFlags.new
    flags.continue_on_error(@continue_on_error)
    @msg.flags(flags)
        .full_collection_name(@coll_name).documents(@docs_to_insert)

  when [Mongo::Wire::RequestMessage::Query]
    flags = Mongo::Wire::RequestMessage::Query::RequestFlags.new
    flags.tailable_cursor(@tailable_cursor).slave_ok(@slave_ok)
         .no_cursor_timeout(@no_cursor_timeout).await_data(@await_data)
         .exhaust(@exhaust).partial(@partial)
    @msg.flags(flags)
        .full_collection_name(@coll_name).number_to_skip(@num_skip_results)
        .number_to_return(@num_return_results).query(@query_doc)
        .return_field_selector(@return_select_doc)

  when [Mongo::Wire::RequestMessage::GetMore]
    @msg.full_collection_name(@coll_name).number_to_return(@num_return_results)
        .cursor_id(@cursor_to_get_more)

  when [Mongo::Wire::RequestMessage::Delete]
    flags = Mongo::Wire::RequestMessage::Delete::RequestFlags.new
    flags.single_remove(@single_remove)
    @msg.flags(flags)
        .full_collection_name(@coll_name).selector(@delete_doc)

  when [Mongo::Wire::RequestMessage::KillCursors]
    @msg.cursor_ids(@cursors_to_delete)

  end

  @wire = @msg.to_wire
end

When /^I parse the message$/ do
  @msg = Mongo::Wire::ResponseMessage::Reply.new(@wire)
end

When /^I generate another message$/ do
  @header_2 = Mongo::Wire::MessageHeader.new
end


Then /^the generated message should match (\S+) ?$/ do |msg|
  @wire.should == [msg].pack('H*')
end

Then /^I should learn that the message has identifier (\d+)$/ do |msg_id|
  @msg.header.get_request_id.should == msg_id.to_i
end

Then /^I should learn that the message is in response to the request with identifier (\d+)$/ do |resp_id|
  @msg.header.get_response_to.should == resp_id.to_i
end

Then /^the opcode should correspond to OP_REPLY$/ do
  #  TODO: make it a constant
  @msg.header.get_message_class.should == Mongo::Wire::ResponseMessage::Reply
end

Then /^I should learn that the cursor ID to get more results is (\d+)$/ do |cur_id|
  @msg.cursor_id.should == cur_id.to_i
end

Then /^I should learn that (\d+) documents are being returned$/ do |num_docs|
  @msg.number_returned.should == num_docs.to_i
end

Then /^I should learn that this reply is starting from (\d+) results into the cursor$/ do |start_from|
  @msg.starting_from.should == start_from.to_i
end

Then /^I should learn that the requested cursor( is (?:not | |))found$/ do |bool|
  @msg.flags.cursor_not_found.should == (not bool)
end
  
Then /^I should learn that the query( is (?:not | |))successful$/ do |bool|
  @msg.flags.query_failure.should == (not bool)
end

Then /^I should learn that the sharding configuration( is (?:not | |))outdated$/ do |bool|
  @msg.flags.shard_config_stale.should == bool
end

Then /^I should learn that the server( is (?:not | |))able to support the await_data query parameter$/ do |bool|
  @msg.flags.await_capable.should == bool
end


Then /^the message should contain the documents (.*)$/ do |docs_str|
  puts docs_str
  docs = JSON[docs_str]
  @msg.documents.should == docs
end


Then /^the two messages should not have the same request ID$/ do
  @header_1.get_request_id.should_not == @header_2.get_request_id
end
