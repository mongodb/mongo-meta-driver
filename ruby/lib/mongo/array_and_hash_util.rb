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

# Adds functionality to Hash
# to make it easier to use with default settings
# and for chaining removals usefully

# TODO: move some or all of this to the cucumber util.rb?
# not all of it is necessarily part of the library
class Hash
  # get a key; if it's not there, get a default value
  def default_get(key, default=nil)
    if member? key and not fetch(key).nil?
      fetch key
    else
      default
    end
  end

  def true_get(key)
    default_get key, true
  end

  def false_get(key)
    default_get key, false
  end

  # delete, returning self (instead of the value of deleted key, the default)
  def silent_delete(key)
    delete key
    self
  end


  # multiset ops
  def multiset_add(item)
    self[item] = (self[item] || 0) + 1
  end

  def multiset_delete(item)
    if self[item] <= 1
      self.delete item
    else
      self[item] = self[item] - 1
    end
  end
end

class Array
  # produce something (essentially) a multiset - a Hash
  # mapping each item in the list to the number of times we've seen it
  def to_multiset
    inject({}) do |multiset, item|
      multiset.multiset_add item
      multiset
    end
  end

  def permutation?(other)
    self.to_multiset == other.to_multiset
  end
end