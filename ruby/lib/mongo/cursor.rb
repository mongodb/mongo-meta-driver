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

module Mongo
  # methods and classes defining wire protocol
  # see http://docs.mongodb.org/meta-driver/latest/legacy/mongodb-wire-protocol/
  module Wire

    # parent class of representations of all parts of wire protocol
    class WireElement
      # error checking.
      # self.send(methods[0], methods[2..]).send(methods[1], ..))
      # if it returns false, return an error message
      # otherwise return nil
      def ensure_element(*methods_msg)
        *methods, msg = methods_msg
        result = methods.inject(self) do |obj, action|
          if action.class == Array
            meth, *args = action
            obj.send(meth, *args)
          else
            obj.send(action)
          end
        end

        if not result
          return msg
        else
          return true
        end
      end
      
      # calls ensure_element; returns true/false
      def ensure_element_boolean(*methods_msg)
        result = ensure_element(*methods_msg)
        return (result == true)
      end
        
      # calls ensure_element; raises an error if it fails
      def ensure_element_fatal(*methods_msg)
        result = ensure_element(*methods_msg)
        if result == true
          return true
        else
          raise ArgumentError, result
        end
      end

      # ensure that the provided object is one of the given types
      def ensure_class(obj, types, msg)
        if types.class == Array
          if not types.member?(obj.class)
            return msg
          else
            return true
          end

        else
          if not types == obj.class
            return msg
          else
            return true
          end
        end
      end
      
      # call ensure_class; return true/false
      def ensure_class_boolean(*methods_msg)
        result = ensure_class(*methods_msg)
        return (result == true)
      end

      # call ensure_element; return true/false
      def ensure_class_fatal(*methods_msg)
        result = ensure_class(*methods_msg)
        if result == true
          return true
        else
          raise ArgumentError, result
        end
      end

      # set up class's internal values
      def set(params)
      end

      def new()
        raise NotImplementedError, "Attempt to create an abstract WireElement"
      end

      # set attributes according to key-value pairs on given map
      def set(map)
        map.each do |key, val|
          keysym = "@#{key}".to_sym
          self.instance_variable_set(keysym, val)
        end
        
        self # return self for fluent-style interface
      end

      # output to wire protocol format
      def to_wire()
        raise NotImplementedError, "Attempt to serialize an abstract WireElement"
      end

      # ensure correctness of parameters
      # if fatal, fail with a message. Otherwise return true/false
      def validate(fatal = false)
        if fatal
          ec = self.
      end
      
      # called by validate to actually check internal variables
      def validate_sub(check_element, check_class)
        raise NotImplementedError, "Attempt to validate an abstract WireElement"        
      end

      private :ensure_element, :ensure_class, :validate_sub
    end

    # message header, common to all message types
    class MessageHeader < WireElement
      # TODO - class names instead?
      RequestOpcodes = {
        :OP_REPLY        => 1, 
        :MSG             => 1000,
        :OP_UPDATE       => 2001,
        :OP_INSERT       => 2002,
        :OP_RESERVED     => 2003,
        :OP_QUERY        => 2004,
        :OP_GET_MORE     => 2005,
        :OP_DELETE       => 2006,
        :OP_KILL_CURSORS => 2007
      }

      attr_reader :message_length
      attr_reader :request_id
      attr_reader :response_to
      attr_reader :opcode

      def initialize()
        # override parent
      end

      def validate(fatal = false)
        if fatal
          ee = self.method(:ensure_element_fatal)
        else
          ee = self.method(:ensure_element_boolean)
        end
        return (    ee.call(:message_length, :bson_int32?, "message length is not an int32")
                and ee.call(:request_id, :bson_int32?, "request ID is not an int32")
                and ee.call(:response_to, :bson_int32?, "response ID of original request is not an int32")
                and ee.call(:opcode, :bson_int32?, "opcode is not an int32")
                and ee.call(:class, [:const_get, :RequestOpcodes], :values, [:member?, opcode], "invalid opcode"))
      end

      def to_wire()
        validate true

        out = ""
        out << message_length.to_bson
        out << request_id.to_bson
        out << response_to.to_bson
        out << opcode.to_bson
        out
      end
    end

    # represent the 32-bit "flags" bitvector that appears in messages
    class RequestFlags < WireElement
      # user-settable flags, in the order they occur in the bitvector
      attr_accessor :tailable_cursor   # is cursor left open after retrieving all data?
      attr_accessor :slave_ok          # allow queries on replica slave?
      attr_accessor :no_cursor_timeout # kill idle cursors?
      attr_accessor :await_data        # block when data unavailable?
      attr_accessor :exhaust           # pull all data at once? (TODO: is this correct?)
      attr_accessor :partial           # try to get results even if some shards are down

      def initialize()
        # override parent
      end

      def validate(fatal = false)
        if fatal
          ec = self.method(:ensure_class_fatal)
        else
          ec = self.method(:ensure_class_boolean)
        end
        
        return (     ec.call(tailable_cursor, [TrueClass, FalseClass], "tailable_cursor is not true or false")
                 and ec.call(slave_ok, [TrueClass, FalseClass], "slave_ok is not true or false")
                 and ec.call(no_cursor_timeout [TrueClass, FalseClass], "no_cursor_timeout is not true or false")
                 and ec.call(await_data, [TrueClass, FalseClass], "await_data is not true or false")
                 and ec.call(exhaust, [TrueClass, FalseClass], "exhaust is not true or false")
                 and ec.call(partial, [TrueClass, FalseClass], "partial is not true or false"))
      end

      def to_wire()
        validate true
        
        # first byte
        b0 = 0
        # bit 0: reserved
        b0 = b0 | 0b00000010 if tailable_cursor
        b0 = b0 | 0b00000100 if slave_ok
        # bit 3: internal use only
        b0 = b0 | 0b00010000 if no_cursor_timeout
        b0 = b0 | 0b00100000 if await_data
        b0 = b0 | 0b01000000 if exhaust
        b0 = b0 | 0b10000000 if partial
        # the next 3 bytes are reserved

        out = ""
        out << b0.to_bson # conveniently, will serialize as an int32
        out
      end
    end

    # describe various types of request messages
    module RequestMessage
      class Update < WireElement
        Opcode = 1
        
        attr_accessor :header
        attr_accessor :full_collection_name
        attr_accessor :flags
        attr_accessor :selector
        attr_accessor :update

        def initialize()
          # override parent
        end

        def validate(fatal = false)
          if fatal
            ec = self.method(:ensure_class_fatal)
          else
            ec = self.method(:ensure_class_boolean)
          end

          return (    ensure_class(header, MessageHeader, "header is not a MessageHeader")
                  and ensure_class(full_collection_name, String, "full collection name is not a String")
                  and ensure_class(flags, RequestFlags, "flags is not a RequestFlags")
                  and ensure_class(selector, Hash, "selector is not a Hash")
                  and ensure_class(update, Hash, "update is not a Hash"))
        end

        def to_wire()
          validate true

          out = ""
          out << header.to_wire
          out << full_collection_name.to_bson
          out << flags.to_wire
          out << selector.to_bson
          out << update.to_bson
          out
        end
      end

    end
  end

  

end
