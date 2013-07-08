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

# implement the MongoDB wire protocol
module Mongo
  # methods and classes defining wire protocol
  # see http://docs.mongodb.org/meta-driver/latest/legacy/mongodb-wire-protocol/
  module Wire

    # parent class of representations of all parts of wire protocol
    class WireElement

      # create chainable setter methods
      # takes a list of 3-tuples: varable name, validation predicate,
      # and error message to return if validation fails
      # predicate takes variable as an argument
      # nil predicate means no validation
      def setter_with_validation(*method_pred_msgs)
        method_pred_msgs.each do |m_p_m|
          method_sym, predicate, msg = m_p_m
          instance_var = "@#{method_sym}".to_sym
          getter_sym = "get_#{method_sym}".to_sym

          define_method method_sym do |val|
            if pred.nil? or (pred val)
              instance_variable_set instance_var, val
              self
            else
              raise ArgumentError, msg
            end
          end

          define_method getter_sym do
            instance_variable_get instance_var
          end
        end
      end

      def initialize
        raise NotImplementedError, "Attempt to create an abstract WireElement"
      end
    end

    # forward declare class names, so they can be referenced in the header class
    module RequestMessage
      class Update      < WireElement; OPCODE = 2001; end
      class Insert      < WireElement; OPCODE = 2002; end
      class Query       < WireElement; OPCODE = 2004; end
      class GetMore     < WireElement; OPCODE = 2005; end
      class Delete      < WireElement; OPCODE = 2006; end
      class KillCursors < WireElement; OPCODE = 2007; end

      # is a class one of the above?
      def valid? clas
        clas == ResponseMessage::Reply  ||
        clas == RequestMessage::Update  ||
        clas == RequestMessage::Insert  ||
        clas == RequestMessage::Query   ||
        clas == RequestMessage::GetMore ||
        clas == RequestMessage::Delete  ||
        clas == RequestMessage::KillCursors
      end
    end

    module ResponseMessage
      class Reply < WireElement; OPCODE = 1; end

      OPCODES_MAP =
      {
        1    => ResponseMessage::Reply
        2001 => RequestMessage::Update
        2002 => RequestMessage::Insert
        2004 => RequestMessage::Query
        2005 => RequestMessage::GetMore
        2006 => RequestMessage::Delete
        2007 => RequestMessage::KillCursors
      }

      # is a class one of the above?
      def valid? clas
        clas == Reply
      end
    end

    # message header, common to all message types
    class MessageHeader < WireElement
      # todo - do i even need the message_length field?
      setter_with_validation
      (
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
        [ # class of containing object
          :message_class,
          lambda {|x|
            ResponseMessage::valid? x ||
            RequestMessage::valid? x
          },
          "invalid message class"
        ],
      )

      def to_wire
        out = ""
        out << @message_length.to_bson
        out << @request_id.to_bson
        # response_to only used for reply messages
        if @message_class != ResponseMessage::Reply
          out << 0.to_bson
        else
          out << @response_to.to_bson
        end
        out << REQUEST_OPCODES.fetch @message_class
        out
      end

      def self.from_wire(message)
        values = message.unpack('l<l<l<l<')[0]
        res = self.new
        res.message_length values[0]
        res.request_id     values[1]
        res.response_to    values[2]
        res.message_class (ResponseMessage::OPCODES_MAP.fetch(values[3]))
        res
      end
    end

    # define objects for request messages
    module RequestMessage

      # OP_UPDATE
      class Update < WireElement
        # flags for update requests
        class RequestFlags < WireElement
          setter_with_validation
          (
            [
              :upsert,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "upsert is not a boolean value"
            ],
            [
              :multi_update,
              lambda {|x|,
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "multi_update is not a boolean value"
            ]
          )

          # last 30 bits reserved
          def to_wire
            b0 = 0
            b0 = b0 | 0b00000001 if @upsert
            b0 = b0 | 0b00000010 if @multi_update
            out = ""
            out << b0.to_bson_int32
            out
          end
        end

        setter_with_validation
        (
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
          ],
          [
            :update,
            lambda {|x| x.class == Hash},
            "update is not of class Hash"
          ]
        )

        def initialize
          @header = MessageHeader.new
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << 0.to_bson # reserved
          out << @full_collection_name.to_bson
          out << @flags.to_wire
          out << @selector.to_bson
          out << @update.to_bson
          out
        end
      end

      # OP_INSERT
      class Insert < WireElement
        class RequestFlags < WireElement
          class RequestFlags < WireElement
            setter_with_validation
            (
              [
                :continue_on_error,
                lambda {|x|
                  x.class == TrueClass ||
                  x.class == FalseClass
                }
              ]
            )

            def to_wire
              # all but first bit reserved
              b0 = 0
              b0 = b0 | 0b00000001 if @continue_on_error
              out = ""
              out << b0.to_bson
              out
            end
          end

          setter_with_validation
          (
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
          )

          def initialize
            @header = MessageHeader.new
            @flags = RequestFlags.new
          end

          def to_wire
            out = ""
            out << header.to_wire
            out << flags.to_wire
            out << full_collection_name.to_bson
            documents.each do |doc|
              out << doc.to_bson
            end
            out
          end
        end
      end

      # OP_QUERY
      class Query < WireElement
        class RequestFlags < WireElement
          setter_with_validation
          (
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
          )

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
            out << b0.to_bson_int32
            out
          end
        end

        setter_with_validation
        (
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
            lambda {|x| x.class == Hash},
            "return_fields_selector is not of type Hash"
          ]
        )

        def initialize
          @header = MessageHeader.new
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << @flags.to_wire
          out << @full_collection_name.to_bson
          out << @number_to_skip.to_bson_int32
          out << @number_to_return.to_bson_int32
          out << @query.to_bson
          out << @return_field_selector.to.bson
          out
        end
      end

      # OP_GET_MORE
      class GetMore <  WireElement
        # does not have flags
        setter_with_validation
        (
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
        )

        def initialize
          @header = MessageHeader.new
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << @header.to_bson
          out << 0.to_bson # reserved
          out << @full_collection_name.to_bson
          out << @number_to_return.to_bson
          out << @cursor_id.to_bson_int64
          out
        end
      end

      # OP_DELETE
      class Delete < WireElement
        class RequestFlags < WireElement
          setter_with_validation
          (
            [
              :single_remove,
              lambda {|x|
                x.class == TrueClass ||
                x.class == FalseClass
              },
              "single_remove is not a boolean value"
            ]
          )

          def to_wire
            # all but first bit reserved
            b0 = 0
            b0 = b0 | 0b00000001 if single_remove
            out = ""
            out << b0.to_bson_int32
            out
          end
        end

        setter_with_validation
        (
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
        )

        def initialize
          @header = MessageHeader.new
          @flags = RequestFlags.new
        end

        def to_wire
          out = ""
          out << header.to_wire
          out << 0.to_bson_int32 # reserved
          out << full_collection_name.to_bson
          out << flags.to_wire
          out << selector.to_bson
          out
        end
      end

      # OP_KILL_CURSORS
      class KillCursors < WireElement
        # does not have flags
        setter_with_validation
        (
          [
            :header,
            lambda {|x| x.class == MessageHeader},
            "header is not of class MessageHeader"
          ],
          [
            :cursor_ids,
            lambda {|x|
              x.class == Array &&
              x.all do |id|
                id.bson_int64?
              end
            },
            "cursor_ids is not an Array of int64s"
          ]
        )

        def initialize
          @header = MessageHeader.new
        end

        def to_wire
          out = ""
          out << @header.to_wire
          out << 0.to_bson_int32 # reserved
          out << @cursor_ids.length.to_bson_int32 # number of cursor ids
          @cursor_ids.each do |id|
            out << id.to_bson_int64
          end
          out
        end
      end
    end

    # define objects for response messages
    module ResponseMessage
      # OP_REPLY
      class Reply < WireElement
        class ResponseFlags < WireElement
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

        def initialize
          # override parent
        end

        def self.from_wire(message)
          res = self.new
          # 4 int32s for message header, then the message
          vals = message.unpack('l<l<l<l<l<q<l<l<a*')

          header_wire = vals.slice(0, 4).pack('l<l<l<l<')
          res.header (MessageHeader.from_wire(header_wire))
          res.flags (new ResponseFlags(vals[4]))

          res.cursor_id       vals[5]
          res.starting_from   vals[6]
          res.number_returned vals[7]

          docs_arr = []
          docs_io = StringIO.new(vals[8])
          while not docs_io.eof?
            docs_arr << Hash.from_bson(docs_io)
          end
          res.documents docs_arr

          res
        end
      end
    end
  end
end