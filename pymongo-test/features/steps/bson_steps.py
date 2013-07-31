from behave import *
import pymongo
import bson
import StringIO
import struct
import re
from bson_transforms import *
from utility import *
from nose.tools import *

# make it use regex, not the less powerful default parser
step_matcher('re')

@step_tr(given, r'^a document containing a ((?:\S+) value (?:.+))$')
def document_containing_value(context, value):
  context.doc = {'k' : value}

# print "doc contain val name: ", document_containing_value.__name__

# TODO change the spec so it's a string not an IO stream
@given('^an IO stream containing ([0-9a-fA-F]+)')
def io_strem_containing(context, bytes):
  # really a string; Python doesn't decode from string IO, unlike Ruby
  context.stream_str = pack_hex(bytes)

@when('^I serialize the document$')
def i_serialize_document(context):
  context.bson = str(bson.BSON.encode(context.doc))

@when('^I deserialize the stream$')
def i_deserialize_stream(context):
  # decode - decode_all operates on a string
  context.out_doc = bson.decode_all(context.stream_str)
        
@then('^the BSON type should correspond to the value type \S+')
def bson_type_should_correspond_value_type(context):
  trivial_pass()  # we can't actually test this, since there is no registry.

@then('^the result should be ([0-9a-fA-F]+)$')
def the_result_should_be_hex(context, hex_bytes):
  context.bson.encode('hex')
  assert_equal( context.bson.encode('hex').lower(), hex_bytes.lower() )

@step_tr(then, '^the result should be the ((?:\S+) value (?:\S+))$')
def the_result_should_be_value_type(context, value):
  # special cases.
  # regexen
  if type(value) == type(re.compile('k')):
    assert_equal( context.out_doc[0]['k'].pattern, value.pattern )
  # TODO: organize these better
  else:
    assert_equal( context.out_doc[0]['k'], value )

@step_tr(then, '^the result should be the binary value (\S+) with binary type (\S+)$')
def the_result_should_be_binary_value_type(context, binary, type):
  if not_provided(type):
    type = bson.binary.BINARY_SUBTYPE

  type = BINARY_TYPES[type]
  binary_obj = bson.binary.Binary(str(binary).strip(), type)
  assert_equal( context.out_doc[0]['k'], binary_obj )

@step_tr(given, '^a (\S+ value(?: .*)?)$')
def a_value(context, value):
  context.value = value

# python driver doesn't have a registry, unlike Ruby
# so just say it passes
@step_tr(given, '^a BSON type ([0-9a-fA-F]+)$')
def a_bson_type(context, type):
  trivial_pass() # noop

@when('^I serialize a document mapping the key (\S+) to the value$')
def i_serialize_the_value(context, key):
  context.bson = str(bson.BSON.encode({key.strip(): context.value}))

# @step_tr(then, '^the value should correspond to the BSON type (\S+)$')
# def value_should_correspond_to_bson_type()

# @step_tr(then, '^the BSON type should correspond to the (value type \S+)$')
# def bson_type_should_correspond_to_value_type(context, type):
#   assert_equal( type, context.value )

# @step_tr(given, '^a (?:\S+) with the following items:$')
# def with_following_items(context, obj):
#   context.value = obj

@step_tr(given, '^an IO stream containing the following BSON document$')
def io_stream_containing_bson_document(context):
  # construct the document
  doc = {}
  for row in context.table:
    print "row: ", row
  # really a string; Python doesn't decode from string IO
  assert_equal( False, True )
  context.stream_str = doc

@then('^the result should be the BSON document:$')
def result_should_be_bson(context, doc):
  assert_equal( context.bson, doc )

@step_tr(then, '^the result should be a (code value .*)$')
def result_should_be_code_value(context, code):
  doccode = context.out_doc[0]['k']
  assert_equal( doccode, code )

@given('^an array with the following items$')
def an_array_with_following_items(context):
  arr = []
  # build up array out of table
  for row in context.table:
    # type, value
    typ = row[0]
    val = row[1]
    res = do_transform('%s value %s' % (typ, val))
    arr.append(res)
  context.value = arr

@given('^a hash with the following items$')
def a_hash_with_following_items(context):
  hash = {}
  # build up hash
  for row in context.table:
    # key, value type, value
    key = row[0].strip()
    typ = row[1]
    val = row[2]
    res = do_transform('%s value %s' % (typ, val))
    hash[key] = res
  context.value = hash

@then('^the result should be the following hash$')
def result_should_be_following_hash(context):
  res_doc = {}
  # build hash
  for row in context.table:
    # key, value type, value
    key = row[0].strip()
    #print key
    typ = row[1]
    val = row[2]
    res = do_transform(u'%s value %s' % (typ, val))
    res_doc[key] = res
  #z = str(bson.BSON.encode(res_doc)).encode('hex')
  #assert_equal(False, True)
  # bson decode instead here
  assert_equal(context.stream_str, bson.BSON.encode(res_doc))

@then('^the result should be a document mapping (\S+) to the following array$')
def result_should_be_doc_mapping_to_following_array(context, key):
  res_arr = []
  key = key.strip()
  for row in context.table:
    typ = row[0]
    val = row[1]
    res = do_transform('%s value %s' % (typ, val))
    res_arr.append(res)
  res_doc = {key : res_arr}
  assert_equal(context.out_doc[0][key], res_doc[key])
  
# TODO this is probably extremely brittle.
@then('^the result should be the BSON document$')
def result_should_be_bson_document(context):
  bson_str = b""
  print type(bson_str)
  for row in context.table:
    typ = row[0]
    name = row[1]
    val = row[2]
    bson_str += pack_hex(typ)
    print type(bson_str)
    bson_str += str(name)
    print type(name)
    print type(bson_str)
    bson_str += b"\x00" # null-terminate
    print type(bson_str)
    bson_str += val.encode('hex')
    print type(bson_str)

  bson_str += b"\x00" # terminate object
  print type(bson_str)
  length = len(bson_str.encode('utf-8')) + 4 # add 4 for length of int itself
  print type(bson_str)
  # little-endian encode string, append it
  bson_str = struct.pack('<I', length) + bson_str
  print type(bson_str)
  assert_equal( context.value, bson.decode_all(bson_str) )
