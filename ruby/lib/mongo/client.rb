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

require "mongo"


# Represents a connection to a MongoDB instance
#
# TODO: add an @since
module Mongo
  class Client
    # describe connection
    class ConnHandle
      def initialize(hostname, port)
        if not hostname.nil? and not port.nil?
          @valid = true
        else
          @valid = false
        end
      end
      def is_valid?
        @valid
      end
    end

    attr_accessor :hostname
    attr_accessor :port
    
    def initialize(hostname, port)
      @hostname = hostname
      @port = port
      @conn = ConnHandle.new(hostname, port)
    end
    
    def connected?
      @conn.is_valid?
    end
  end
end
