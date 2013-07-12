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

# Creating OP_GET_MORE messages
# As part of the Wire Protocol

module Mongo
  module Wire
    module RequestMessage
      class GetMore
        class << self; include WireUtil; end

        # does not have flags
        access_with_validation [
          [
            :header,
            lambda {|x| x.class == MessageHeader},
            "header is not of class MessageHeader"
          ],
          [
            :full_collection_name,
            lambda {|x| x.class == String},
            "full_collection_name is not of class String"
          ],
          [
            :number_to_return,
            lambda {|x| x.bson_int32?},
            "number_to_return is not an int32"
          ],
          [
            :cursor_id,
            lambda {|x| x.bson_int64?},
            "cursor_id is not an int64"
          ]
        ]

        def initialize
          @header = MessageHeader.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << [0].pack('l<') # reserved
          out << @full_collection_name.to_bson_cstring
          out << [@number_to_return].pack('l<')
          out << [@cursor_id].pack('q<')
          MessageHeader.fix_length out
        end
      end
    end
  end
end