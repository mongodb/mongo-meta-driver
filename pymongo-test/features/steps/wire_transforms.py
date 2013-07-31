from behave import *
import pymongo
import json
from utility import *
from nose.tools import assert_equal

# TODO - figure out which str() and strip() calls are actually necessary

# look up the pymongo functions corresponding to the operation names
OPNAME_TO_FUNCTION = {
  "OP_UPDATE"       : pymongo.message.update,
  "OP_INSERT"       : pymongo.message.insert,
  "OP_QUERY"        : pymongo.message.query,
  "OP_GET_MORE"     : pymongo.message.get_more,
  "OP_DELETE"       : pymongo.message.delete,
  "OP_KILL_CURSORS" : pymongo.message.kill_cursors
}

@transform(r'^generating an? (\S+) message$')
def transform_message_type(opname):
  type_func_pair = (opname, OPNAME_TO_FUNCTION[str(opname).strip()])
  return type_func_pair

@transform(r'^the document (.*)$')
def transform_document(doc_str):
  if not_provided(doc_str):
    return None
  else:
    return json.loads(doc_str)

@transform(r'^I am (not | |).+$')
def transform_i_am_or_not(empty_or_not):
  return not_provided(empty_or_not)

@transform(r'^ is (not | |)$')
def transform_is_or_not(empty_or_not):
  return not_provided(empty_or_not)

# ignore ID fields, for easier comparison of raw messages
# ID fields are the second four bytes in the message
def assert_equal_irrespective_of_ids(msg1, msg2):
  assert_equal( msg1[0:4], msg2[0:4] )
  assert_equal( msg1[8:],  msg2[8:] )