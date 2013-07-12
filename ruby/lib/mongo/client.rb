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

# Represents a connection to a MongoDB instance
#
# TODO: add an @since
require 'socket'
require 'wire'
require 'timeout'
module Mongo
  class Client
    # describe connection
    attr_reader :hostname, :port, :error

    DEFAULT_CONN_TIMEOUT = 5
    DEFAULT_PORT=27017

    # opts is a hash containing extra options, including
    # port: which tcp port to connect to
    # timeout: float, number of seconds to wait before giving up on socket connection
    def initialize(hostname, opts={})
      @valid = false
      if hostname.nil?
        raise ArgumentError.new('Hostname cannot be nil')
      end
      @hostname = hostname

      @port = opts[:port]
      @port ||= DEFAULT_PORT

      # ensure connection attempt does not hang for too long
      timeout = opts[:timeout]
      timeout ||= DEFAULT_CONN_TIMEOUT
      begin
        @socket = timeout(timeout) do
          TCPSocket.new(@hostname, @port)
        end
        @valid = true
      rescue
        @socket = nil
        @error = "Unable to connect to #{@hostname}:#{@port}." # TODO add a reason
        @valid = false
      end
    end

    def valid?
      @valid
    end

    # TODO: have a validation function to check socket connectedness

    def get_db(dbname)
      Database.new(dbname, @socket, self)
    end

    def [] (dbname)
      get_db dbname
    end
  end
end
