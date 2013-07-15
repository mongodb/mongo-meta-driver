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

# Creating OP_DELETE messages
# As part of the Wire Protocol

module Mongo
  module Wire
    module RequestMessage
      class Delete
        class << self; include WireUtil; end

        class RequestFlags
          class << self; include WireUtil; end

          access_with_validation [
            [
              :single_remove,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "single_remove is not a boolean value"
            ]
          ]

          def to_wire
            # all but first bit reserved
            b0 = 0
            b0 = b0 | 0b00000001 if @single_remove
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
            :full_collection_name,
            lambda {|x| x.class == String},
            "full_collection_name is not of class String"
          ],
          [
            :flags,
            lambda {|x| x.class == RequestFlags},
            "flags is not of class RequestFlags"
          ],
          [
            :selector,
            lambda {|x| x.class == Hash},
            "selector is not of class Hash"
          ]
        ]

        def initialize
          @header = MessageHeader.new
          @header.message_class(self.class)
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << [0].pack('l<') # reserved
          out << @full_collection_name.to_bson_cstring
          out << @flags.to_wire
          out << @selector.to_bson
          MessageHeader.fix_length out
        end
      end
    end
  end
end