from behave import *
import pymongo
import bson
import StringIO
import struct
import re
import json
from wire_transforms import *
from utility import *
from nose.tools import *

# TODO - figure out which str() and strip() calls are actually necessary
# make it use regex, not the less powerful default parser
step_matcher('re')

# step definitions for wire protocol
@given('^my request will have an ID of (\d+)$')
def my_request_will_have_id(context, id):
  context.id = int(id)

@given('^I am using the collection "(.*)"$')
def i_am_using_collection(context, name):
  context.coll_name = str(name)

@step_tr(given, '^I am (generating an? \S+ message)$')
def i_am_generating_message(context, op_type):
  # transform gives us a pair: (name, function)
  # TODO this transform may no longer be necessary
  context.msg_type = op_type[0]
  context.msg_function = op_type[1]

@step_tr(given, '^I am performing the update specified by (the document .*)$')
def i_am_performing_update_specified(context, doc):
  context.update_spec_doc = doc

@step_tr(given, '^I am selecting fields to return by (the document .*)$')
def i_am_selecting_return_field(context, doc):
  context.return_select_doc = doc

@step_tr(given, '^I am updating(?: the)? documents? matching (the document .*)$')
def i_am_updating_documents(context, doc):
  context.update_doc = doc

@step_tr(given, '^I am querying for documents matching (the document .*)$')
def i_am_querying_documents(context, doc):
  context.query_doc = doc

@step_tr(given, '^I am deleting documents matching (the document .*)$')
def i_am_deleting_documents(context, doc):
  context.delete_doc = doc

@given('^I am requesting results for the cursor with id (\d+)$')
def i_am_requesting_cursor_results(context, cur_id):
  context.cursor_to_get_more = int(cur_id)

@step_tr(given, '^I am inserting (the document .*)$')
def i_am_inserting_document(context, doc):
  context.docs_to_insert = [doc]

@given('^I am inserting the documents$')
def i_am_inserting_documents(context):
  docs = []
  for row in context.table:
    print "item!: ", row[0]
    doc = json.loads(row[0].strip())
    docs.append(doc)

  context.docs_to_insert = docs

@given('^I am deleting the cursors with ids$')
def i_am_deleting_cursors(context):
  cursors = []
  for row in context.table:
    cursors.append(int(row[0]))

  context.cursors_to_delete = cursors

# non-binary options
@given('^I am skipping (\d+) results$')
def i_am_skipping_results(context, num):
  context.skip_num = int(num)

@given('^I am returning (\d+) results$')
def i_am_returning_results(context, num):
  context.return_num = int(num)

@given('^MongoDB has responded with the OP_REEPLY message (\S+)$')
def mongodb_responded_with_reply(context, wire):
  context.wire = wire.encode('hex')

@given('^I have generated a message$')
def i_generated_message(context):
  # noop
  return

# binary flags

@step_tr(given, '^(I am (?:not | |)doing an upsert)$')
def i_am_doing_upsert(context, yesno):
  context.upsert = yesno

@step_tr(given, '^(I am (?:not | |)doing a multi update)$')
def i_am_doing_multi_update(context, yesno):
  context.multi_update = yesno

@step_tr(given, '^(I am (?:not | |)doing a continue on error)$')
def i_am_doing_continue_error(context, yesno):
  context.continue_on_error = yesno

@step_tr(given, '^(I am (?:not | |)doing a tailable cursor query)$')
def i_am_doing_tailable_cursor(context, yesno):
  context.tailable_cursor = yesno

@step_tr(given, '^(I am (?:not | |)permitting querying of a replica slave)$')
def i_am_permitting_replica_slave_query(context, yesno):
  context.slave_ok = yesno

@step_tr(given, '^(I am (?:not | |)permitting idle cursors to persist)$')
def i_am_permitting_idle_cursors(context, yesno):
  context.no_cursor_timeout = yesno

@step_tr(given, '^(I am (?:not | |)permitting cursors to block and wait for more data)$')
def i_am_permitting_cursors_to_await(context, yesno):
  context.await_data = yesno

@step_tr(given, '^(I am (?:not | |)pulling all queried data at once)$')
def i_am_pulling_all_data_at_once(context, yesno):
  context.exhaust = yesno

@step_tr(given, '^(I am (?:not | |)permitting partial results if a shard is down)$')
def i_am_permitting_partial_results(context, yesno):
  context.partial = yesno

@step_tr(given, '^(I am (?:not | |)permitting removal of multiple documents)$')
def i_am_permitting_multiple_documents_remove(context, yesno):
  context.single_remove = (not yesno)

# actually generating the message!
# TODO - UUID subtype will change
@when('^I generate the wire protocol message for this request$')
def i_generate_wire_protocol_message(context):
  typ = context.msg_type
  if   typ == 'OP_UPDATE':
    msg = pymongo.message.update(
      context.coll_name, context.upsert, context.multi_update,
      context.update_spec_doc, context.update_doc,
      False, [], False, bson.binary.OLD_UUID_SUBTYPE
    )

  elif typ == 'OP_INSERT':
    print "about to insert"
    print context.docs_to_insert
    msg = pymongo.message.insert(
      context.coll_name, context.docs_to_insert, 
      False, False, [], context.continue_on_error, bson.binary.OLD_UUID_SUBTYPE
    )

  elif typ == 'OP_QUERY':
    # we have to put together our query options by hand.
    flags = 0
    # bit 0 reserved
    flags |= (0b00000010 if context.tailable_cursor else 0)
    flags |= (0b00000100 if context.slave_ok else 0)
    # driver does not set bit 3
    flags |= (0b00010000 if context.no_cursor_timeout else 0)
    flags |= (0b00100000 if context.await_data else 0)
    flags |= (0b01000000 if context.exhaust else 0)
    flags |= (0b10000000 if context.partial else 0)

    msg = pymongo.message.query(
      flags, context.coll_name, context.skip_num, context.return_num,
      context.query_doc, context.return_select_doc,
      bson.binary.OLD_UUID_SUBTYPE
    )

  elif typ == 'OP_GET_MORE':
    msg = pymongo.message.get_more(
      context.coll_name, context.return_num, context.cursor_to_get_more
    )

  elif typ == 'OP_DELETE':
    msg = pymongo.message.delete(
      context.coll_name, context.delete_doc,
      False, [], bson.binary.OLD_UUID_SUBTYPE
    )

  elif typ == 'OP_KILL_CURSORS':
    msg = pymongo.message.kill_cursors(context.cursors_to_delete)

  else:
    msg = ""
    print "invalid message type ", typ
    assert(False) # if we get here something is wrong with our scenario or steps

  context.wire = msg

@when('^I parse the message$')
def i_parse_message(context):
  context.response_props = pymongo.helpers._unpack_response(context.msg)

@then('^the generated message should match (\S+) ?$')
def generated_message_should_match(context, msg):
  generated_message = context.wire[1] # we get back a tuple apparently
  # remove request IDs, since they won't reliably be the same
  msg = pack_hex(msg)
  assert_equal_irrespective_of_ids( generated_message, msg )

# @then('^I should learn that the message has identifier (\d+)')
# def i_should_learn_message_id(context, id):
#   assert_equal ( context.response_props[""], int(id) )

# @then('^I should learn that the message is in response to the request with identifier (\d+)$')
# def i_should_learn_message_id(context, id):
#   assert_equal

# @then('^the opcode should correspond to OP_REPLY$')

@then('^I should learn that the cursor ID to get more results is (\d+)$')
def i_should_learn_cursor_id(context, cur_id):
  assert_equal( context.response_props["cursor_id"], int(cur_id) )

@then('^I should learn that (\d+) documents are being returned$')
def i_should_learn_num_documents_returned(context, num_docs):
  assert_equal( context.response_props["number_returned"], int(num_docs) )

@then('^I should learn that this reply is starting from (\d+) results into the cursor$')
def i_should_learn_reply_start_from(context, start_from):
  assert_equal( context.response_props["starting_from"], int(start_from) )

#
# error-checking code doesn't seem to translate well to python
#

@then('^the message should contain the documents (.*)$')
def message_should_contain_documents(context, docs_str):
  docs = json.loads(docs_str.strip())
  assert_equal( context.documents, docs )

# @then('^the two messages should not have the same request ID$')