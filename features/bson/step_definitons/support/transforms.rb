RUBY_TRANSFORM = {
  :double       => lambda {|arg| arg.to_f                 },
  :string       => lambda {|arg| arg.to_s                 },
  :hash         => lambda {|arg| Hash[arg]                },
  :undefined    => lambda {|arg| BSON::Undefined          },
  :object_id    => lambda {|arg| BSON::ObjectId.new       },
  :true         => lambda {|arg| true                     },
  :false        => lambda {|arg| false                    },
  :datetime     => lambda {|arg| Time.new(arg)            },
  :null         => lambda {|arg| nil                      },
  :regex        => lambda {|arg| /#{arg}/                 },
  # TODO - handle this better?
  :db_pointer   => lambda {|arg| lambda{nil}              },
  :code         => lambda {|arg| Code.new(arg)            },
  :symbol       => lambda {|arg| arg.to_sym               },
  # TODO - what about scope?
  :code_w_scope => lambda {|arg| CodeWithScope.new(arg)   },
  :int32        => lambda {|arg| arg.to_i                 },
  :timestamp    => lambda {|arg| BSON::Timestamp.new      },
  :int64        => lambda {|arg| arg.to_i                 },
  :min_key      => lambda {|arg| BSON::MinkKey            },
  :max_key      => lambda {|arg| BSON::MaxKey             }
}

BSON_TO_RUBY_TYPE = {
  :double => Float,
  :string => String,
  :document => Hash,
  :array => Array,
  :binary => BSON::Binary,
  :undefined => BSON::Undefined,
  :object_id => BSON::ObjectId,
  :boolean => BSON::Boolean,
  :datetime => Time,
  :null => NilClass,
  :regex => Regexp,
  :db_pointer => nil,
  :code => BSON::Code,
  :symbol => Symbol,
  :code_w_scope => BSON::CodeWithScope,
  :int32 => BSON::Int32,
  :timestamp => BSON::Timestamp,
  :int64 => BSON::Int64,
  :min_key => BSON::MinKey,
  :max_key => BSON::MaxKey
}

Transform /^double value(?: (-?\d+\.?\d+))?$/ do |double|
  double.to_f
end

Transform /^string value(?: (\S+))?$/ do |string|
  string.to_s
end

Transform /^document value(?: (\S+))?$/ do |document|
  Hash.new
end

Transform /^array value(?: (\[.*\]))?$/ do |array|
  Array.new
end

Transform /^binary value(?: (\S+)(?: with binary type (\S+))?)?$/ do |binary, type|
  type = type ? type.to_sym : type
  puts "\nbinary transform\n"
  BSON::Binary.new(binary.to_s.strip, type)
end

Transform /^undefined value(?: (\S+))?$/ do |undefined|
  BSON::Undefined
end

Transform /^object_id value(?: (\S+))?$/ do |obj_id|
  begin
    oid = BSON::ObjectId.from_string(obj_id)
  rescue BSON::ObjectId::Invalid
    oid = BSON::ObjectId.from_string("50d3409d82cb8a4fc7000001")
  end
  oid
end

Transform /^boolean value(?: (\S+))?$/ do |boolean|
  boolean == 'true'
end

Transform /^datetime value(?: (\S+))?$/ do |datetime|
  Time.at(datetime.to_i)
end

Transform /^null value(?: (\S+))?$/ do |null|
  nil
end

Transform /^symbol value(?: (\S+))?$/ do |symbol|
  symbol.to_sym
end

# probably unneeded; see the "code value" case, which is more readable
Transform /^code_w_scope value(?: (\S+))?$/ do |code|
  BSON::CodeWithScope.new(code.to_s, {:a => 1})
end

Transform /^regex value(?: (\S+))?$/ do |regex|
  /#{regex}/
end

# db_pointer is deprecated, and not supported by this implementation.
# we use a lambda so it doesn't conflict with other things
# (we don't have too many other options. kind of a gross hack)
Transform /^db_pointer value(?: (\S+))?$/ do |db_pointer|
  lambda {true}
end

# TODO: make this not use an eval.
# TODO: change delimeter from " to something that won't appear in js code
Transform /^code value(?: \"(.+)\"(?: with scope (.+)?)?)?.*$/ do |code, scope|
  puts "\nCODE: #{code} SCOPE: #{scope}\n\n"
  if scope.nil?
    BSON::Code.new(code.to_s)
  else
    BSON::CodeWithScope.new(code.to_s, eval(scope.to_s))
  end
end

Transform /^symbol value(?: (\S+))?$/ do |symbol|
  symbol.to_s.intern
end

Transform /^int32 value(?: (-?\d+))?$/ do |int32|
  int32.to_i
end

Transform /^timestamp value(?: (-?\d+))?$/ do |ts|
  BSON::Timestamp.new(Time.now, 0)
end

Transform /^int64 value(?: (-?\d+))?$/ do |int64|
 int64 ? int64.to_i : 2**62
end

Transform /^min_key value(?: (\S+))?$/ do |min_key|
  BSON::MinKey
end

Transform /^max_key value(?: (\S+))?$/ do |max_key|
  BSON::MaxKey
end

Transform /^value type (\S+)$/ do |type|
  BSON_TO_RUBY_TYPE.fetch(type.to_sym)
end

 #based on the transforms below
 Transform /^BSON value (\S+) with BSON type (\S+)$/ do |value, bson_type|
  bson = String.new
  bson << [bson_type].pack("H*")
  bson << bson_type
  bson << "example".to_bson_cstring
  bson << [value].pack("H*")
  bson << "\x00"
  # unsure what this does exactly. pad?
  StringIO.new([[bson.bytesize + 4].pack(BSON::Int32::PACK), bson].join)
end

Transform /^table:value_type,value$/ do |table|
  table.map_headers! { |header| header.downcase.to_sym }
  table.hashes.map do |hash|
    RUBY_TRANSFORM[hash[:value_type].to_sym].call(hash[:value])
  end
end

Transform /^table:key,value_type,value$/ do |table|
  table.map_headers! { |header| header.downcase.to_sym }
  table.hashes.inject(Hash.new) do |h, r|
    h[r[:key]] = RUBY_TRANSFORM[r[:value_type].to_sym].call(r[:value])
    h
  end
end

Transform /^table:bson_type,e_name,value$/ do |table|
  table.map_headers! { |header| header.downcase.to_sym }
  bson = table.hashes.inject(String.new) do |bson, element|
    bson << [element[:bson_type]].pack("H*")
    bson << element[:e_name].to_bson_cstring
    bson << [element[:value]].pack("H*")
    bson
  end
  bson << "\x00"
  [[bson.bytesize + 4].pack(BSON::Int32::PACK), bson].join
end

