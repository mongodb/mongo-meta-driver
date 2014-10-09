# Copyright (C) 2009-2014 MongoDB, Inc.
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

Feature: Replica Set Configuration
  In order to support changes to the configuration of a replica set
  As a driver author
  I want to verify that the driver correctly behaves according to documentation and specification
  http://docs.mongodb.org/manual/reference/command/nav-replication/
  https://github.com/mongodb/specifications/tree/master/source/server-discovery-and-monitoring

  @pending
  @destroy
  Scenario: Member is added to replica set
    #  Trigger an immediate topology check, and assert that within a few seconds the
    #  member appears in the TopologyDescription with the proper ServerType and tags.

  @pending
  @destroy
  Scenario: Member is removed from replica set
    #  Trigger an immediate topology check, and assert that within a few seconds the
    #  member appears in the TopologyDescription with the proper ServerType and tags.
