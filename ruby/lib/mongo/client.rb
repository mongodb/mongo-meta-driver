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
    attr_reader :hostname, :port, :socket, :error

    CONN_TIMEOUT_SEC = 5

    def initialize(hostname, port)
      @connected = false
      if hostname.nil? or port.nil?
        raise ArgumentError.new('Hostname and port cannot be nil')
      end
      @hostname = hostname
      @port = port

      # ensure socket does not hang forever
      begin
        @socket = timeout(CONN_TIMEOUT_SEC) do
          TCPSocket.new(@hostname, @port)
        end
      rescue
        @socket = nil
        @error = 'Connection failed.' # TODO add a reason
      end

      @connected = true
    end

    def connected?
      @connected
    end

    # TODO: have a validation function to check socket connectedness

    def get_db(dbname)
      Database.new(@socket, dbname)
    end

    def [] (dbname)
      get_db dbname
    end
  end
end
