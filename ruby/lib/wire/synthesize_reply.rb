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

# Mock responses from MongoDB
# Used for testing the wire protocol's reply deserializer

module Mongo::Wire::Mocking
  def mock_flags(cur_not_found = false, query_failure = false, shard_config_stale = false, await_capable = false)
    b0 = 0
    b0 = b0 | 0b00000001 if cur_not_found
    b0 = b0 | 0b00000010 if query_failure
    b0 = b0 | 0b00000100 if shard_config_stale
    b0 = b0 | 0b00001000 if await_capable
    b0
  end
  module_function :mock_flags

  def mock_reply(req_id, resp_to, flags, cur_id, start_from, num_returned, docs)
    out = ""
    # header
    out << [0].pack('l<') # set aside space for length
    out << [req_id].pack('l<')
    out << [resp_to].pack('l<')
    out << [1].pack('l<') # opcode
    # flags
    out << [flags].pack('l<')
    # rest
    out << [cur_id].pack('q<')
    out << [start_from].pack('l<')
    out << [num_returned].pack('l<')
    docs.each do |doc|
      out << doc.to_bson
    end
    Mongo::Wire::MessageHeader.fix_length out
  end
  module_function :mock_reply
end