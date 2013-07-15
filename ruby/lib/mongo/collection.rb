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

# Represents a collection on a database on a connected MongoDB instance
#
require 'wire'
module Mongo
  class Client
    class Collection
      attr_reader :name, :error

      # should only be called from database
      def initialize(collname, socket, db)
        @valid = false
        @name = collname
        @socket = socket
        @db = db
        if @db.valid?
          @valid = true
        else
          @error = "Failed to get collection #{@name} because invalid database was given."
        end
      end

      # insert (a) document(s) into the collection
      def insert(one_or_more_docs, opts = {})
        cmd = Mongo::Wire::RequestMessage::Insert.new
        cmd.flags.continue_on_error (opts['continue_on_error'] == true)
        cmd.
      end
    end
  end
end
