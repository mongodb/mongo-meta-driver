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

# Creating OP_INSERT messages
# As part of the Wire Protocol

module Mongo
  module Wire
    module RequestMessage
      class Insert
        class << self; include WireUtil; end
        # flags for insert
        class RequestFlags
          class << self; include WireUtil; end
          access_with_validation [
            [
              :continue_on_error,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "continue_on_error is not a boolean value"
            ]
          ]

          def to_wire
            # all but first bit reserved
            b0 = 0
            b0 = b0 | 0b00000001 if @continue_on_error
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
            :documents,
            lambda {|x|
              x.class == Array &&
              x.all? do |doc|
                doc.class == Hash
              end
            },
            "documents is not an Array of Hashes"
          ]
        ]

        def initialize
          @header = MessageHeader.new
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << @flags.to_wire
          out << @full_collection_name.to_bson_cstring
          @documents.each do |doc|
            out << doc.to_bson
          end
          MessageHeader.fix_length out
        end
      end
    end
  end
end