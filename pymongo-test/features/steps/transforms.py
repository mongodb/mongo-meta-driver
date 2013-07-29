from behave import *
import pymongo
import bson
import json
import datetime
import pytz
import re
from utility import *

# TODO - do I even really need all these...?
BINARY_TYPES = {
  'generic'  : bson.binary.BINARY_SUBTYPE,
  'function' : bson.binary.FUNCTION_SUBTYPE,
  'old'      : bson.binary.OLD_BINARY_SUBTYPE,
  'uuid_old' : bson.binary.OLD_UUID_SUBTYPE,
  'uuid'     : bson.binary.UUID_SUBTYPE,
  'md5'      : bson.binary.MD5_SUBTYPE,
  'user'     : bson.binary.USER_DEFINED_SUBTYPE
}

BSON_TO_PYTHON_TYPE = {
  'double' : float,
  'string' : str,
  'document' : dict,
  'array' : list,
  'binary' : bson.binary.Binary,
  'object_id' : bson.objectid.ObjectId,
  'boolean' : bool,
  'datetime' : datetime.datetime,
  'null' : type(None),
  'regex' : type(re.compile('')),
  'code' : bson.code.Code,
  'code_w_scope' : bson.code.Code,
  'int32' : int,
  'timestamp' : bson.timestamp.Timestamp,
  'int64' : int,
  'min_key' : bson.min_key.MinKey,
  'max_key' : bson.max_key.MaxKey
}

PYTHON_TRANSFORM = {
  'double'       : (lambda arg: float(arg)),
  'string'       : (lambda arg: str(arg)),
  'hash'         : (lambda arg: dict(arg)),
  'object_id'    : (lambda arg: bson.objectid.ObjectId()),
  'true'         : (lambda arg: True),
  'false'        : (lambda arg: False),
  'datetime'     : (lambda arg: time.gmtime(arg)),
  'null'         : (lambda arg: None),
  'regex'        : (lambda arg: re.compile(arg)),
  # TODO - handle this better?
  'code'         : (lambda arg: bson.code.Code(arg)),
  # TODO - what about scope?
  'code_w_scope' : (lambda arg: bson.code.Code(arg,{})),
  'int32'        : (lambda arg: int(arg)),
  'timestamp'    : (lambda arg: bson.timestamp.Timestamp(datetime.datetime.now(), 0)),
  'int64'        : (lambda arg: int(arg)),
  'min_key'      : (lambda arg: bson.min_key.MinKey),
  'max_key'      : (lambda arg: bson.max_key.MaxKey)                                         
}


# helper function for identifying empty arguments
def not_provided(arg):
  return (arg is None or arg.strip() == "")

@transform(r"^double value(?: (-?\d+\.?\d+))?$")
def transform_double_value(val):
  if not_provided(val):
    return float()
  return float(val)

@transform(r"^string value(?: (\S+))?$")
def transform_string_value(val):
  return str(val)

# is this even used?
@transform(r"^binary value(?: (\S+)(?: with binary type (\S+))?)?$")
def transform_binary_value(val, type):
  # check for nullness of value?
  if not_provided(type):
    type = 'generic'
  return bson.binary.Binary(str(val).strip(), BINARY_TYPES[type])

# undefined - deprecated

@transform(r"^object_id value(?: (\S+))?$")
def transform_object_id_value(val):
  try:
    oid = bson.objectid.ObjectId(val)
  except pymongo.errors.InvalidId:
    oid = bson.objectid.ObjectId("50d3409d82cb8a4fc7000001")
  return oid

@transform(r"^boolean value(?: (\S+))?$")
def transform_boolean_value(val):
  return (val == 'true')

# TODO: is this the correct type?
@transform(r"^datetime value(?: (\S+))?$")
def transform_datetime_value(val):
  if not_provided(val):
    time = int()
  else:
    time = int(val)
  dt = datetime.datetime.fromtimestamp(time, bson.tz_util.utc) # bson timezone, so we can compare it
  # make sure it has the same offset-awareness as what we get from BSON serialization/deserialization
  return dt

@transform(r"^null value(?: (\S+))?$")
def transform_null_value(val):
  return None

@transform(r"^regex value(?: (\S+))?$")
def transform_regex_value(val):
  if not_provided(val):
    rex = ""
  else:
    rex = str(val)
  return re.compile(rex)

# db pointer - deprecated

@transform(r"^code value(?: \"(.+)\"(?: with scope (.+)?)?)?$")
def transform_code_value(code, scope):
  if not_provided(scope):
    return bson.code.Code(str(code))
  else:
    return bson.code.Code(str(code), json.loads(scope))

# also deprecated
# @transform(r"^symbol value(?: (\S+))?$")
# def transform_symbol_value(val):
#   return str(val)

@transform(r"^int32 value(?: (-?\d+))?$")
def transform_int32_value(val):
  if not_provided(val):
    return 0
  else:
    return int(val)

@transform(r"^timestamp value(?: (-?\d+))?$")
def transform_timestamp_value(val):
  return bson.timestamp.Timestamp(datetime.datetime.now(), 0)

# TODO - validate that it's really an int64??
@transform(r"^int64 value(?: (-?\d+))?$")
def transform_int64_value(val):
  if not_provided(val):
    return 2**62
  else:
    return int(val)

@transform(r"^min_key value(?: (\S+))?$")
def transform_min_key_value(val):
  return bson.min_key.MinKey

@transform(r"^max_key value(?: (\S+))?$")
def transform_max_key_value(val):
  return bson.max_key.MaxKey

@transform(r"^value type (\S+)$")
def transform_value_type(typ):
  BSON_TO_PYTHON_TYPE[str(typ)]

# implement this only if necessary
# @transform(r"^BSON value (\S+) with BSON type (\S+)$")
# def transform_bson_value_with_bson_type(val, typ):
#   bson = ""
#   bson += 

# @transform(r"^table:value_type,value$")
# def transform_value_type_value_table(table):
#   for row in table.iterrows():
#     print row
