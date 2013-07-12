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

# TODO: properly memoize everything to avoid excess object creation
# Represents a database on a connected MongoDB instance
#
require 'socket'
require 'wire'
module Mongo
  class Client
    class Database
      attr_reader :name, :error

      # should only be called from client
      def initialize(dbname, socket, client)
        @valid = false
        @name = dbname
        @socket = socket
        @client = client
        if @client.valid?
          @valid = true
        else
          @error = "Failed to get database #{@name} because invalid client was given."
        end
      end

      def get_coll(collname)
        Collection.new(@socket, collname)
      end

      def [] (collname)
        get_coll collname
      end

      # check whether this is a db on the given client object
      def is_on_client?(client)
        @client.equal? client
      end

      def valid?
        @valid
      end
    end
  end
end
