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

Feature: Sharded Cluster Connection
  In order to support changes to the state of a sharded cluster
  As a driver author
  I want to verify that the driver correctly behaves according to documentation and specification
  https://github.com/mongodb/specifications/tree/master/source/server-discovery-and-monitoring

  Scenario: Insert with mongos Router Stop and Start
    Given a sharded cluster with preset basic
    When I insert a document
    Then the insert succeeds
    When I stop router A
    And I insert a document with retries
    Then the insert succeeds
    When I stop router B
    And I insert a document
    Then the insert fails
    When I start router B
    And I insert a document
    Then the insert succeeds
    When I start router A
    And I insert a document
    Then the insert succeeds
    When I stop router B
    And I insert a document with retries
    Then the insert succeeds

  Scenario: Query Auto-retry with mongos Router Stop and Start
    # See https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst#requests-and-auto-retry
    # Auto-retry - mongos fail-over - query succeeds without error/exception as long as one mongos is available
    Given a sharded cluster with preset basic
    And a document written to the cluster
    When I query
    Then the query succeeds
    When I stop router A
    When I query
    Then the query succeeds
    When I stop router B
    When I query
    Then the query fails
    When I start router B
    When I query
    Then the query succeeds
    When I start router A
    When I query
    Then the query succeeds
    When I stop router B

  Scenario: Insert with mongos Router Restart
    Given a sharded cluster with preset basic
    When I insert a document
    Then the insert succeeds
    When I stop router A
    And I insert a document with retries
    Then the insert succeeds
    When I restart router B
    And I insert a document with retries
    Then the insert succeeds

  Scenario: Query Auto-retry with mongos Router Restart
    # See https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst#requests-and-auto-retry
    # Auto-retry - mongos fail-over - query succeeds without error/exception as long as one mongos is available
    Given a sharded cluster with preset basic
    And a document written to the cluster
    When I query
    Then the query succeeds
    When I stop router A
    And I query
    Then the query succeeds
    When I restart router B
    And I query
    Then the query succeeds
