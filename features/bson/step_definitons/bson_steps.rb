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
  @document = Hash.from_bson(@io)
end

Then /^the result should be ([0-9a-fA-F]+)$/ do |hex_bytes|
  @bson.unpack('H*')[0].should eq(hex_bytes)
end

Then /^the result should be the ((?:\S+) value (?:\S+))$/ do |value|
  @document['k'].should eq(value)
end

Given /^a (\S+ value(?: .*)?)$/ do |value|
  puts "\n\n\nVALUE IS\ #{value}n\n\n"
  @value = value
end

When /^I serialize the value$/ do
  @bson = @value.to_bson
end

Then /^the BSON element should have the (BSON type \S+)$/ do |type|
  #p @bson
  pending
end

Then /^the value should correspond to the (BSON type \S+)$/ do |type|
  if @value.class == Proc
    # How we handle deprecated things (like DB pointers). Hacky.
    @value.call # ought to return true
    
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

Then /^the result should be the bson document:$/ do |doc|
  @bson.should == doc
end

