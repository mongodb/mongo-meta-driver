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

# TODO: write concern?

require 'wire'
module Mongo
  class Client
    class Collection
      attr_reader :name, :error

      # utilities
      def is_on_db(db)
        @db.equal? db
      end

      def valid?
        @valid
      end

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

      def full_name
        "#{@db.name}.#{@name}"
      end

      # CRUD ops
      # insert (a) document(s) into the collection
      # TODO: sensible defaults
      def insert(one_or_more_docs, opts = {})
        docs = one_or_more_docs
        if one_or_more_docs.class == Hash
          docs = [one_or_more_docs]
        end
        cmd = Mongo::Wire::RequestMessage::Insert.new
        cmd.flags.continue_on_error(opts['continue_on_error'])
        cmd.full_collection_name(full_name)
           .documents(docs)
        @socket.send(cmd.to_wire)
      end

      def remove(selector = {}, opts = {})
        cmd = Mongo::Wire::RequestMessage::Delete.new
        cmd.flags.single_remove(opts['single_remove'])
        cmd.full_collection_name(full_name)
           .selector(selector)
        @socket.send(cmd.to_wire)
      end

      def find(query_doc = {}, return_fields = nil, n_skip = 0, n_ret = 0, opts = {})
        cmd = Mongo::Wire::RequestMessage::Query.new
        timeout = opts['timeout'] # wait 5s for a response (or user specified)
        timeout ||= 5
        cmd.flags.tailable_cursor(opts['tailable_cursor']).slave_ok(opts['slave_ok'])
                 .no_cursor_timeout(opts['no_cursor_timeout'])
                 .await_data(opts['await_data']).exhaust(opts['exhaust'])
                 .partial(opts['partial'])
        cmd.full_collection_name(full_name)
           .query(query_doc).return_field_selector(return_fields)
           .number_to_skip(n_skip).number_to_return(n_ret)

        @socket.send(cmd.to_wire)

        # get a response
        result = Mongo::Wire::ResponseMessage::Reply.new(@socket)
        result
      end

    end
  end
end
