# TODO: look in serialize.featur2e for <value_type>
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
  @document = Hash.from_bson(@io)
end

Then /^the result should be ([0-9a-fA-F]+)$/ do |hex_bytes|
  @bson.unpack('H*')[0].should eq(hex_bytes)
end

Then /^the result should be the ((?:\S+) value (?:\S+))$/ do |value|
  @document['k'].should eq(value)
end

Given /^a (\S+ value(?: .*)?)$/ do |value|
  @value = value
end

When /^I serialize the value$/ do
  @bson = @value.to_bson
end

# deserializing a value isn't so simple
# since we need its type
When /^I deserialize the value$/ do
  @deserialized = Hash.from_bson(@value)
  p @deserialized
  raise "STOOOOOOP"
end

# unneeded?
Then /^the BSON element should have the (BSON type \S+)$/ do |type|
  pending
end

Then /^the value should correspond to the (BSON type \S+)$/ do |type|
  if @value.class == Proc
    # How we handle deprecated things (like DB pointers). Hacky.
    @value.call # ideally, defined to return something meaningful
    
  elsif @value.respond_to? :bson_type
    # the typical case
    @value.bson_type.should == type
    
  else
    # if value doesn't respond to bson_type, there is no ruby equivalent
    # in this case value is (probably) actually a class

    @value::BSON_TYPE.should == type
  end
end
  
Given /^a (?:\S+) with the following items:$/ do |obj|
  @value = obj
end

Given /^the following BSON document:$/ do |doc|
  @value = doc
end

Then /^the result should be the bson document:$/ do |doc|
  @bson.should == doc
end

Then /^the result should be the array:$/ do |array|
  @deserialized.should == array
end

Then /^the BSON type should correspond to the (value type \S+)$/ do |type|
  type.should == BSON::Registry.get(@value)
end
