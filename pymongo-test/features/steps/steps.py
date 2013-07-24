from behave import *
import pymongo
import bson
import StringIO
import struct
from utility import *

# def hex_to_packed_binary(hex_str):
#   digits = [int(x, 16) for x in hex_str]
#   d

# @step_tr(given, '^a document containing a ((?:\S+) value (?:.+))$')
# def document_containing_value(value):
#   print "here we are. setting context."
#   context.doc = {'k' : value}
#   print "set context, yay!"

# @given('^a document containing a ((?:\S+) value (?:.+))$')
# def document_containing_value(value):
#   context.doc = {'k' : value}

# TODO change the spec so it's a string not an IO stream
@given('^an IO stream containing ([0-9a-fA-F]+)')
def io_stream_containing_hex_bytes(bytes):
  # really a string; Python doesn't decode from string IO, unlike Ruby
  context.stream_str = pack_hex(bytes)

# @when('^I serialize the document$')
# def i_serialize_document():
#   context.bson = bson.BSON.encode(context.doc)

# @when('^I deserialize the stream$')
# def i_deserialize_stream():
#   # decode - decode_all operates on a string
#   print "stream str is ", type(context.stream_str)
#   context.out_doc = bson.decode_all(context.stream_str)
#   print "decoded context. it is ", context.out_doc

# @then('^the result should be ([0-9a-fA-F]+)$')
# def the_result_should_be_hex(hex_bytes):
#   assert_equal( context.bson.decode('hex'), hex_bytes )

# @then('^the result should be the ((?:\S+) value (?:\S+))$')
# def the_result_should_be_value_type(value):
#   print context.out_doc
#   assert_equal( context.out_doc[0]['k'], value )

# @then('^the result should be the binary value (\S+) with binary type (\S+)$')
# def the_result_should_be_binary_value_type(binary, type):
#   if not_provided(type):
#     type = bson.binary.BINARY_SUBTYPE

#   binary_obj = bson.binary.Binary(str(binary).strip(), type)
#   assert_equal( context.out_doc['k'], binary_obj )

# @given('^a (\S+ value(?: .*)?)$')
# def a_value(value):
#   context.value = value

# # python driver doesn't have a registry, unlike Ruby
# # @given('^a BSON type ([0-9a-fA-F]+)$')
# # def a_bson_type(type):
# #   # db pointer
# #   if type.upper() == "0C":
# #     context.value = None
# #   else:
# #     context.value = 

# @when('^I serialize the value')
# def i_serialize_the_value():
#   context.bson = bson.BSON.encode(context.value)

# # @then('^the value should correspond to the BSON type (\S+)$')
# # def value_should_correspond_to_bson_type()

# # @then('^the BSON type should correspond to the (value type \S+)$')
# # def bson_type_should_correspond_to_value_type(type):
# #   assert_equal( type, context.value )

# @given('^a (?:\S+) with the following items:$')
# def with_following_items(obj):
#   context.value = obj

# @given('^an IO stream containing the following BSON document:$')
# def io_stream_containing_bson_document(doc):
#   # really a string; Python doesn't decode from string IO
#   context.stream_str = doc

# @then('^the result should be the BSON document:$')
# def result_should_be_bson(doc):
#   assert_equal( context.bson, doc )

# @then('^the result should be a (code value .*)$')
# def result_should_be_code_value(code):
#   doccode = context.out_doc['k']
#   assert_equal( doccode, code )

# # result should be of the form {0 : first_elem, 1 : second_elem, ...}
# @then('^the result should be a hash corresponding to the following array:$')
# def result_should_be_hash_corresponding_to_array(lst):
#   idx = 0
#   res_lst = []
#   for key, val in context.out_doc.iteritems():
#     assert_equal( len(pair), 2 )
#     assert_equal( key, idx )
#     accum.append(val)

#   assert_equal( res_lst, lst )

# @then('^the result should be the following hash:$')
# def result_should_be_hash(hash):
#   assert_equal( context.out_doc, hash )