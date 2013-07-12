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

# Declarations for RequestMessage and ResponseMessage classes
# Both of which derive from WireElement (see element.rb)

# forward declare class names, so they can be referenced 
# for looking up opcodes
module Mongo
  module Wire
    module RequestMessage
      class Update;      OPCODE = 2001; end
      class Insert;      OPCODE = 2002; end
      class Query;       OPCODE = 2004; end
      class GetMore;     OPCODE = 2005; end
      class Delete;      OPCODE = 2006; end
      class KillCursors; OPCODE = 2007; end

       # is a class one of the above?
       def valid? clas
        clas == Update  ||
        clas == Insert  ||
        clas == Query   ||
        clas == GetMore ||
        clas == Delete  ||
        clas == KillCursors
      end
      module_function :valid?
    end

    module ResponseMessage
      class Reply; OPCODE = 1; end

      OPCODES_MAP =
      {
        1    => ResponseMessage::Reply,
        2001 => RequestMessage::Update,
        2002 => RequestMessage::Insert,
        2004 => RequestMessage::Query,
        2005 => RequestMessage::GetMore,
        2006 => RequestMessage::Delete,
        2007 => RequestMessage::KillCursors
      }

      # is a class one of the above?
      def valid? clas
        clas == Reply
      end
      module_function :valid?
    end
  end
end