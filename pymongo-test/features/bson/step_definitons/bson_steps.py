from lettuce import step

#
# transforms
#

#
# steps
#

# useful constants
binary_types = {
  'generic'  : bson.binary.BINARY_SUBTYPE,
  'function' : bson.binary.FUNCTION_SUBTYPE,
  'old'      : bson.binary.OLD_BINARY_SUBTYPE,
  'uuid_old' : bson.binary.OLD_UUID_SUBTYPE,
  'uuid'     : bson.binary.UUID_SUBTYPE,
  'md5'      : bson.binary.MD5_SUBTYPE,
  'user'     : bson.binary.USER_DEFINED_SUBTYPE
}

contain = u'a document containing an? '

# steps
@step(contain + u'double value (.+)'):
def document_containing_double_value(step, value):
  world.doc = {'k' : float(value)}

@step(contain + u'string value (.+)'):
def document_containing_string_value(step, value):
  world.doc = {'k' : str(value))

@step(contain + u'binary value (.+) with binary type (\S+)'):
def document_containing_binary_value(step, value, type_str):
  bin = bson.binary.Binary(str(value), binary_types[type_str])
  world.doc = {'k' : bin}

# undefined deprecateds
# @step(u'a document containing an undefined value (.+)'):
# def document_containing_undefined_value(step, value):
#   bson.

@step(contain + u'object_id value (\S+)'):
def document_containing_object_id_value(step, value):
  try:
    oid = pymongo.objectid.ObjectId(value)
  except pymongo.errors.InvalidId:
    oid = pymongo.objectid.ObjectId("50d3409d82cb8a4fc7000001")
  world.doc = {'k' : oid}

@step(contain + u'boolean value (\S+)'):
def document_containing_boolean_value(step, value):
  world.doc = {'k' : (value == 'true')}

@step(contain + u'datetime value (\S+)'):
def document_containing_datetime_value(step, value):
  world.doc = 

@step(u'a BSON type (\S+)):
def given_bson_type(step, typ):

