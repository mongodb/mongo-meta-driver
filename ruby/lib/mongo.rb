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

#require "mongo/environment"
$:.unshift(File.dirname(__FILE__))
require 'bson'

# The core namespace for the client-facing sections of the driver
#
# TODO: add an @since
module Mongo
  # constants
end

require 'mongo/wire'
require 'mongo/array_and_hash_util'
require 'mongo/client'
require 'mongo/database'
require 'mongo/collection'
#require "mongo/protocol"
# # require "mongo/cluster"
# require "mongo/collection"
#require "mongo/cursor"

# require "mongo/database"
# require "mongo/node"
# require "mongo/pool"

# load relevant extensions?

