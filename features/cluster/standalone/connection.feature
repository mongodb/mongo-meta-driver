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

Feature: Standalone Server Connection
  In order to support changes to the state of a standalone server
  As a driver author
  I want to verify that the driver correctly behaves according to documentation and specification
  https://github.com/mongodb/specifications/tree/master/source/server-discovery-and-monitoring

  Scenario: Server is stopped and started
    Given a standalone server with preset basic
    When I insert a document
    Then the insert succeeds
    When I stop the server
    And I insert a document
    Then the insert fails
    When I start the server
    And I insert a document
    Then the insert succeeds

  Scenario: Server is restarted
    Given a standalone server with preset basic
    When I insert a document
    Then the insert succeeds
    When I restart the server
    And I insert a document with retries
    Then the insert succeeds
