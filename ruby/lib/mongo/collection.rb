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
      def insert(one_or_more_docs, opts = {})
        docs = one_or_more_docs
        docs = [one_or_more_docs] if one_or_more_docs.class != Array

        cmd = Mongo::Wire::RequestMessage::Insert.new
        cmd.get_flags.continue_on_error(opts.false_get :continue_on_error)
        cmd.full_collection_name(full_name)
           .documents(docs)
        @socket.send(cmd.to_wire, 0)
      end

      def find(query_doc = {}, return_fields = nil, n_skip = 0, n_ret = 0, opts = {})
        n_skip ||= 0
        n_ret ||= 0
        cmd = Mongo::Wire::RequestMessage::Query.new
        timeout = opts['timeout'] # wait 5s for a response (or user specified)
        timeout ||= 5
        cmd.get_flags.tailable_cursor(opts.false_get :tailable_cursor)
                     .slave_ok(opts.false_get :slave_ok)
                     .no_cursor_timeout(opts.false_get :no_cursor_timeout)
                     .await_data(opts.false_get :await_data)
                     .exhaust(opts.false_get :exhaust)
                     .partial(opts.false_get :partial)

        cmd.full_collection_name(full_name)
           .query(query_doc)
           .return_field_selector(return_fields)
           .number_to_skip(opts.default_get :skip_num, 0)
           .number_to_return(opts.default_get :return_num, 0)

        @socket.send(cmd.to_wire, 0)

        # get a response (return it)
        timeout(timeout) do
          Mongo::Wire::ResponseMessage::Reply.new(@socket)
        end
      end

      def update(selector = {}, update_spec = {}, opts = {})
        cmd = Mongo::Wire::RequestMessage::Update.new
        cmd.get_flags.upsert(opts.false_get :upsert).multi_update(opts.false_get :multi_update)
        cmd.full_collection_name(full_name)
           .selector(selector).update(update_spec)

        @socket.send(cmd.to_wire, 0)
      end

      def remove(selector = {}, opts = {})
        cmd = Mongo::Wire::RequestMessage::Delete.new
        cmd.get_flags.single_remove(opts.false_get :single_remove)
        cmd.full_collection_name(full_name)
           .selector(selector)
        @socket.send(cmd.to_wire, 0)
      end

    end
  end
end
