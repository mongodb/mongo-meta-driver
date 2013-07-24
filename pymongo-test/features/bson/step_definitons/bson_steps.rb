# TODO: look in serialize.feature for <value_type>
Given /^a document containing a ((?:\S+) value (?:.+))$/ do |value|
  @doc = {:k => value}
end

Given /^an IO stream containing ([0-9a-fA-F]+)$/ do |hex_bytes|
  @io = StringIO.new([hex_bytes].pack('H*'))
end

When /^I serialize the document$/ do
  @bson = @doc.to_bson
end

When /^I deserialize the stream$/ do
  @out_doc = Hash.from_bson(@io)
end

Then /^the result should be ([0-9a-fA-F]+)$/ do |hex_bytes|
  @bson.unpack('H*')[0].should eq(hex_bytes)
end

Then /^the result should be the ((?:\S+) value (?:\S+))$/ do |value|
  @out_doc['k'].should eq(value)
end

# based on a similar transform from transforms.rb which doesn't work for some reason
Then /^the result should be the binary value (\S+) with binary type (\S+)$/ do |binary, type|
  type = type ? type.to_sym : type
  binary_obj = BSON::Binary.new(binary.to_s.strip, type)
  @out_doc['k'].should eq(binary_obj)
end

Given /^a (\S+ value(?: .*)?)$/ do |value|
  @value = value
end

Given /^a BSON type ([0-9a-fA-F]+)$/ do |type|
  # db pointer
  if type == "0C"
    @value = nil
  else
    @value = BSON::Registry.get([type].pack("H*"))
  end
end

When /^I serialize the value$/ do
  @bson = @value.to_bson
end

# unneeded?
#Then /^the BSON element should have the (BSON type \S+)$/ do |type|
#  pending
#end

Then /^the value should correspond to the BSON type (\S+)$/ do |type|
  typecode = [type].pack("H*")
  if @value.class == Proc
    # How we handle deprecated things (like DB pointers). Hacky.
    @value.call.should == true # ought to return true
    
  elsif @value.respond_to? :bson_type
    # the typical case
    @value.bson_type.should == typecode
    
  else
    # if value doesn't respond to bson_type, there is no ruby equivalent
    # in this case value is (probably) actually a class

    @value::BSON_TYPE.should == typecode
  end
end

Then /^the BSON type should correspond to the (value type \S+)$/ do |type|
  # ensure corresponding Ruby types are the same. See transforms.rb for this mapping
  type.should == @value
end
  
Given /^a (?:\S+) with the following items:$/ do |obj|
  @value = obj
end

Given /^an IO stream containing the following BSON document:$/ do |doc|
  @io = StringIO.new(doc)
end

Then /^the result should be the BSON document:$/ do |doc|
  @bson.should == doc
end

Then /^the result should be a (code value .*)$/ do |code|
  doccode = @out_doc['k']
  doccode.javascript.should == code.javascript
  if code.class == BSON::CodeWithScope || doccode.class == BSON::CodeWithScope
    doccode.scope.should == code.scope
  end
end

# TODO make this a transform
# the result should be of the form { 0 => first_elem, 1 => second_elem ...}
Then /^the result should be a hash corresponding to the following array:$/ do |array|
  # process the array, verifying its structure
  res_array = (@out_doc.inject([0, []]) do |acc, key_val|
    key_val.length.should == 2
    [key, val] = key_val
    [index, vals] = acc
    key.to_i.should == index
    [index + 1, vals << val]
  end).last
  # verify contents
  res_array.should == array
end

Then /^the result should be the following hash:$/ do |hash|
  @out_doc.should == hash
end

