from freshen import *
import pymongo
import bson
import StringIO
import struct

# utilities for marshalling data into and out of binary form
def pack_hex(hex_str):
  if len(hex_str) % 2 != 0:
    hex_str += '0'
  return hex_str.decode('hex')

# helper function for identifying empty arguments
def not_provided(arg):
  return (arg is None or arg.strip() == "")

# def hex_to_packed_binary(hex_str):
#   digits = [int(x, 16) for x in hex_str]
#   d

@Given('^a document containing a ((?:\S+) value (?:.+))$')
def document_containing_value(value):
  scc.doc = {'k' : value}

# TODO change the spec so it's a string not an IO stream
@Given('^an IO stream containing ([0-9a-fA-F]+)')
def io_stream_containing_hex_bytes(bytes):
  # really a string; Python doesn't decode from string IO, unlike Ruby
  scc.stream_str = pack_hex(bytes)

@When('^I serialize the document$')
def i_serialize_document():
  scc.bson = bson.BSON.encode(scc.doc)

@When('^I deserialize the stream$')
def i_deserialize_stream():
  # decode - decode_all operates on a string
  print "stream str is ", type(scc.stream_str)
  scc.out_doc = bson.decode_all(scc.stream_str)
  print "decoded scc. it is ", scc.out_doc

@Then('^the result should be ([0-9a-fA-F]+)$')
def the_result_should_be_hex(hex_bytes):
  assert_equal( scc.bson.decode('hex'), hex_bytes )

@Then('^the result should be the ((?:\S+) value (?:\S+))$')
def the_result_should_be_value_type(value):
  print scc.out_doc
  assert_equal( scc.out_doc[0]['k'], value )

@Then('^the result should be the binary value (\S+) with binary type (\S+)$')
def the_result_should_be_binary_value_type(binary, type):
  if not_provided(type):
    type = bson.binary.BINARY_SUBTYPE

  binary_obj = bson.binary.Binary(str(binary).strip(), type)
  assert_equal( scc.out_doc['k'], binary_obj )

@Given('^a (\S+ value(?: .*)?)$')
def a_value(value):
  scc.value = value

# python driver doesn't have a registry, unlike Ruby
# @Given('^a BSON type ([0-9a-fA-F]+)$')
# def a_bson_type(type):
#   # db pointer
#   if type.upper() == "0C":
#     scc.value = None
#   else:
#     scc.value = 

@When('^I serialize the value')
def i_serialize_the_value():
  scc.bson = bson.BSON.encode(scc.value)

# @Then('^the value should correspond to the BSON type (\S+)$')
# def value_should_correspond_to_bson_type()

# @Then('^the BSON type should correspond to the (value type \S+)$')
# def bson_type_should_correspond_to_value_type(type):
#   assert_equal( type, scc.value )

@Given('^a (?:\S+) with the following items:$')
def with_following_items(obj):
  scc.value = obj

@Given('^an IO stream containing the following BSON document:$')
def io_stream_containing_bson_document(doc):
  # really a string; Python doesn't decode from string IO
  scc.stream_str = doc

@Then('^the result should be the BSON document:$')
def result_should_be_bson(doc):
  assert_equal( scc.bson, doc )

@Then('^the result should be a (code value .*)$')
def result_should_be_code_value(code):
  doccode = scc.out_doc['k']
  assert_equal( doccode, code )

# result should be of the form {0 : first_elem, 1 : second_elem, ...}
@Then('^the result should be a hash corresponding to the following array:$')
def result_should_be_hash_corresponding_to_array(lst):
  idx = 0
  res_lst = []
  for key, val in scc.out_doc.iteritems():
    assert_equal( len(pair), 2 )
    assert_equal( key, idx )
    accum.append(val)

  assert_equal( res_lst, lst )

@Then('^the result should be the following hash:$')
def result_should_be_hash(hash):
  assert_equal( scc.out_doc, hash )