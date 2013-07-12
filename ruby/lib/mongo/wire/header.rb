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

# Defines the header common to all wire-protocol messages
module Mongo
  module Wire
    # message header, common to all message types
    class MessageHeader
      class << self; include WireUtil; end
      # todo - do i even need the message_length field?
      access_with_validation [
        [ 
          :message_length,
          lambda {|x| x.bson_int32?},
          "message length is not an int32"
        ],
        [ 
          :request_id,
          lambda {|x| x.bson_int32?},
          "request ID is not an int32"
        ],
        [
          :response_to,
          lambda {|x| x.bson_int32?},
          "response ID of original request is not an int32"
        ],
        [ 
          # class of containing object
          :message_class,
          lambda {|x|
            ResponseMessage.valid?(x) ||
            RequestMessage.valid?(x)
          },
          "invalid message class"
        ]
      ]

      def to_wire
        out = ""
        # placeholder for length; gets filled in by fix_length
        if @message_length.nil?
          out << [0].pack('l<')
        else
          out << [@message_length].pack('l<')
        end
        out << [@request_id].pack('l<')
        # response_to only used for reply messages
        if @message_class != ResponseMessage::Reply
          out << [0].pack('l<')
        else
          out << [@response_to].pack('l<')
        end
        out << [Mongo::Wire::ResponseMessage::OPCODES_MAP.invert.fetch(@message_class)].pack('l<')
        out
      end

      # add length back into an already-serialized message
      def self.fix_length(message)
        bytes = message.length
        # take off first 4 bytes
        rest = message.byteslice(4..-1)
        out = [bytes].pack('l<')
        out << rest
        out
      end

      def self.from_wire(message)
        values = message.unpack('l<l<l<l<')
        res = self.new
        res.message_length values[0]
        res.request_id     values[1]
        res.response_to    values[2]
        res.message_class (ResponseMessage::OPCODES_MAP.fetch(values[3]))
        res
      end
    end
  end
end