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

# Creating OP_QUERY messages
# As part of the Wire Protocol

module Mongo
  module Wire
    module RequestMessage
      class Query
        class << self; include WireUtil; end
        class RequestFlags
          class << self; include WireUtil; end
          access_with_validation [
            [
              :tailable_cursor,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "tailable_cursor is not a boolean value"
            ],
            [
              :slave_ok,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "slave_ok is not a boolean value"
            ],
            [
              :no_cursor_timeout,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "no_cursor_timeout is not a boolean value"
            ],
            [
              :await_data,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "await_data is not a boolean value"
            ],
            [
              :exhaust,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "exhaust is not a boolean value"
            ],
            [
              :partial,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "partial is not a boolean value"
            ]
          ]

          def to_wire
            # last 24 bits reserved
            # plus bits 0 and 3 in first byte
            b0 = 0
            b0 = b0 | 0b00000010 if @tailable_cursor
            b0 = b0 | 0b00000100 if @slave_ok
            b0 = b0 | 0b00010000 if @no_cursor_timeout
            b0 = b0 | 0b00100000 if @await_data
            b0 = b0 | 0b01000000 if @exhaust
            b0 = b0 | 0b10000000 if @partial
            out = ""
            out << [b0].pack('l<')
            out
          end
        end

        access_with_validation [
          [
            :header,
            lambda {|x| x.class == MessageHeader},
            "header is not of class MessageHeader"
          ],
          [
            :flags,
            lambda {|x| x.class == RequestFlags},
            "flags is not of class RequestFlags"
          ],
          [
            :full_collection_name,
            lambda {|x| x.class == String},
            "full_collection_name is not of class String"
          ],
          [
            :number_to_skip,
            lambda {|x| x.bson_int32?},
            "number_to_skip is not an int32"
          ],
          [
            :number_to_return,
            lambda {|x| x.bson_int32?},
            "number_to_return is not an int32"
          ],
          [
            :query,
            lambda {|x| x.class == Hash},
            "query is not of class Hash"
          ],
          [
            :return_field_selector,
            lambda {|x| x.nil? || x.class == Hash},
            "return_field_selector is not of type Hash (or nil)"
          ]
        ]

        def initialize
          @header = MessageHeader.new
          @header.message_class(self.class)
          @flags = RequestFlags.new
          @number_to_skip = 0
          @number_to_return = 0
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << @flags.to_wire
          out << @full_collection_name.to_bson_cstring
          out << [@number_to_skip].pack('l<')
          out << [@number_to_return].pack('l<')
          out << @query.to_bson
          if not @return_field_selector.nil?
            out << @return_field_selector.to_bson
          end
          MessageHeader.fix_length out
        end
      end      
    end
  end
end