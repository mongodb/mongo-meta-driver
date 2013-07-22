$:.unshift(File.dirname(__FILE__) + '/../../bson-ruby/lib')
$:.unshift(File.dirname(__FILE__) + '/../../ruby/lib')
require 'mongo' # production ruby driver
require 'json'