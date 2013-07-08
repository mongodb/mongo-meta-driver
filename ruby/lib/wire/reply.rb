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

# Creating OP_REPLY messages
# As part of the Wire Protocol
module Mongo
  module Wire
    # define objects for response messages
    module ResponseMessage
      # OP_REPLY
      class Reply
        class << self; include WireUtil; end
        class ResponseFlags
          class << self; include WireUtil; end
          # boolean flags
          attr_reader :cursor_not_found
          attr_reader :query_failure
          attr_reader :shard_config_stale
          attr_reader :await_capable

          def initialize(vector)
            # 32-bit
            @cursor_not_found = false
            @cursor_not_found = true    if vector & 0b00000001 != 0
            @query_failure = false
            @query_failure = true       if vector & 0b00000010 != 0
            @shard_config_stale = false
            @shard_config_stale = true  if vector & 0b00000100 != 0
            @await_capable = false
            @await_capable = true       if vector & 0b00001000 != 0
          end
        end

        attr_reader :header          # MessageHeader
        attr_reader :flags           # ResponseFlags
        attr_reader :cursor_id       # int64
        attr_reader :starting_from   # int32
        attr_reader :number_returned # int32
        attr_reader :documents       # Array of Hashes

        # deserialize a reply message from the wire
        def initialize(message)
          # 4 int32s for message header, then the message
          vals = message.unpack('l<l<l<l<l<q<l<l<a*')

          header_wire = vals.slice(0, 4).pack('l<l<l<l<')
          @header = MessageHeader.from_wire(header_wire)
          @flags  = ResponseFlags.new(vals[4])

          @cursor_id       = vals[5]
          @starting_from   = vals[6]
          @number_returned = vals[7]

          docs_arr = []
          docs_io = StringIO.new(vals[8])
          while not docs_io.eof?
            docs_arr << Hash.from_bson(docs_io)
          end
          @documents = docs_arr
        end
      end
    end
  end
end