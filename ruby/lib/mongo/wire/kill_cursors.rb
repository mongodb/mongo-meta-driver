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

# Creating OP_KILL_CURSORS messages
# As part of the Wire Protocol

module Mongo
  module Wire
    module RequestMessage
      class KillCursors
        class << self; include WireUtil; end
        # does not have flags
        access_with_validation [
          [
            :header,
            lambda {|x| x.class == MessageHeader},
            "header is not of class MessageHeader"
          ],
          [
            :cursor_ids,
            lambda {|x|
              x.class == Array &&
              x.all? do |id|
                id.bson_int64?
              end
            },
            "cursor_ids is not an Array of int64s"
          ]
        ]

        def initialize
          @header = MessageHeader.new
          @header.message_class(self.class)
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << [0].pack('l<') # reserved
          out << [@cursor_ids.length].pack('l<') # number of cursor ids
          @cursor_ids.each do |id|
            out << [id].pack('q<')
          end
          MessageHeader.fix_length out
        end
      end
    end
  end
end