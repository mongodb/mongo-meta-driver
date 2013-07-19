# Copyright (C) 2013 10gen Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Utility functions to assist in testing
# Called from step definitions

class Array
  # assert that this array is a permutation of other
  def should_be_permutation_of(other)
    self.to_multiset.should == other.to_multiset
  end
end

# convert an array of symbols into a hash
# mapping that symbol to the value of instance variable with that name
def hashify(symbols)
  acc = {}
  symbols.each do |symbol|
    acc[symbol] = instance_variable_get ("@#{symbol}".to_sym)
  end
  acc
end