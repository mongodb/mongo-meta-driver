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

Feature: Read Preference
  In order to support read preference that describes how clients route read operations to members of a replica set
  As a driver author
  I want to verify that the driver correctly behaves according to documentation and specification
  http://docs.mongodb.org/manual/core/read-preference/
  https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst

  Scenario: Read Primary
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference PRIMARY
    Then the query occurs on the primary
    When there is no primary
    And I query with read-preference PRIMARY
    Then the query fails

  Scenario: Read Primary Preferred
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference PRIMARY_PREFERRED
    Then the query occurs on the primary
    When there is no primary
    And I track server status on secondaries
    And I query with read-preference PRIMARY_PREFERRED
    Then the query occurs on the secondary

  Scenario: Read Secondary
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference SECONDARY
    Then the query occurs on a secondary
    When there are no secondaries
    When I query with read-preference SECONDARY
    Then the query fails

  Scenario: Read Secondary Preferred
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference SECONDARY_PREFERRED
    Then the query occurs on a secondary
    When there are no secondaries
    And I track server status on the primary
    And I query with read-preference SECONDARY_PREFERRED
    Then the query occurs on the primary

  Scenario: Read With Nearest
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I query with read-preference NEAREST
    Then the query succeeds

  Scenario: Read Primary With Tag Sets
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I query with read-preference PRIMARY and tag sets [{"ordinal": "one"}, {"dc": "ny"}]
    Then the query fails with error "PRIMARY cannot be combined with tags"

  Scenario: Read Primary Preferred With Tag Sets
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}, {"dc": "pa"}]
    Then the query occurs on the primary
    When there is no primary
    And I track server status on secondaries
    And I query with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}]
    Then the query occurs on the secondary
    When I query with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "three"}, {"dc": "na"}]
    Then the query fails with error "No replica set member available for query with read preference matching mode PRIMARY_PREFERRED and tags matching <tags sets>."

  Scenario: Read Secondary With Tag Sets
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference SECONDARY and tag sets [{"ordinal": "two"}]
    Then the query occurs on a secondary
    When I query with read-preference SECONDARY and tag sets [{"ordinal": "one"}]
    Then the query fails with error "No replica set member available for query with read preference matching mode SECONDARY and tags matching <tags sets>."

  Scenario: Read Secondary Preferred With Tag Sets
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "two"}]
    Then the query occurs on a secondary
    When I track server status on all data members
    And I query with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "three"}]
    Then the query occurs on the primary

  @ruby_1_x_broken
  Scenario: Read Nearest With Tag Sets
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I query with read-preference NEAREST and tag sets [{"ordinal": "one"}]
    Then the query occurs on the primary
    When I track server status on all data members
    And I query with read-preference NEAREST and tag sets [{"ordinal": "two"}]
    Then the query occurs on a secondary
    When I query with read-preference NEAREST and tag sets [{"ordinal": "three"}]
    Then the query fails with error "No replica set member available for query with read preference matching mode NEAREST and tags matching <tags sets>"

  Scenario Outline: Secondary OK Commands
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I run a <db_type> <name> command with read-preference SECONDARY and with example <example>
    Then the command occurs on a <member_type>
    Examples:
      | member_type | db_type | name      | example | comment |
      | secondary   | normal  | collStats | { "collStats": "test" } | |
      | secondary   | normal  | count     | { "count": "test" } | |
      | secondary   | normal  | dbStats   | { "dbStats": 1 } | |
      | secondary   | normal  | distinct  | { "distinct": "test", "key": "a" } | |
      | secondary   | normal  | group     | { "group": { "ns": "test", "key": "a", "$reduce": "function ( curr, result ) { }", "initial": { } } } | |
      | secondary   | normal  | isMaster  | { "isMaster": 1 } | |
      | secondary   | normal  | parallelCollectionScan | { "parallelCollectionScan": "test", "numCursors": 2 } | |

  Scenario: Secondary OK GeoNear
    Given a replica set with preset arbiter
    And some geo documents written to all data-bearing members
    And a geo 2d index
    When I track server status on all data members
    And I run a geonear command with read-preference SECONDARY
    Then the command occurs on a secondary

  Scenario: Secondary OK GeoSearch
    Given a replica set with preset arbiter
    And some geo documents written to all data-bearing members
    And a geo geoHaystack index
    When I track server status on all data members
    And I run a geosearch command with read-preference SECONDARY
    Then the command occurs on a secondary

  Scenario: Secondary OK MapReduce with inline
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I track server status on all data members
    And I run a map-reduce with field out value inline true and with read-preference SECONDARY
    Then the command occurs on a secondary

  Scenario: Primary Reroute MapReduce without inline
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I track server status on all data members
    And I run a map-reduce with field out value other than inline and with read-preference SECONDARY
    Then the command occurs on the primary

  Scenario: Secondary OK Aggregate without $out
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I track server status on all data members
    And I run an aggregate without $out and with read-preference SECONDARY
    Then the command occurs on a secondary

  Scenario: Primary Reroute Aggregate with $out
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I track server status on all data members
    And I run an aggregate with $out and with read-preference SECONDARY
    Then the command occurs on the primary

  Scenario Outline: Primary Reroute Primary-Only Commands
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    When I track server status on all data members
    And I run a <db_type> <name> command with read-preference SECONDARY and with example <example>
    Then the command occurs on the <member_type>
    Examples:
      | member_type | db_type | name           | example | comment |
      #| primary     | normal  | buildInfo      | { "buildInfo": 1 } | |
      #| primary     | normal  | collMod        | { "collMod": "test", "usePowerOf2Sizes": 1 } | |
      #| primary     | normal  | create         | { "create": "test" } | |
      #| primary     | normal  | delete         | { "delete": "test", "deletes": [{"q": {"a": 1}, "limit": 1}] } | |
      #| primary     | normal  | drop           | { "drop": "test" } | |
      #| primary     | normal  | dropDatabase   | { "dropDatabase": 1 } | |
      #| primary     | normal  | eval           | { "eval": "function(){ return {x: 1} }" } | |
      #| primary     | normal  | findAndModify  | { "findAndModify": "test", "query": {"a": 1}, "update": {"$inc": {"a": 1}} } | |
      | primary     | admin   | fsync          | { "fsync": 1 } | |
      #| primary     | admin   | getCmdLineOpts | { "getCmdLineOpts": 1 } | |
      #| primary     | normal  | getLastError   | { "getLastError": 1 } | |
      #| primary     | admin   | getParameter   | { "getParameter": 1, "logLevel": 1 } | |
      #| primary     | normal  | getPrevError   | { "getPrevError": 1 } | |
      #| primary     | admin   | getLog         | { "getLog": "*" } | |
      #| primary     | normal  | hostInfo       | { "hostInfo": 1 } | |
      #| primary     | normal  | insert         | { "insert": "test", "documents": [{"b": 2},{"c": 3}] } | |
      #| primary     | normal  | listCommands   | { "listCommands": 1 } | |
      #| primary     | admin   | listDatabases  | { "listDatabases": 1 } | |
      #| primary     | admin   | logRotate      | { "logRotate": 1 } | |
      | primary     | normal  | ping           | { "ping": 1 } | |
      #| primary     | normal  | profile        | { "profile": 0 } | |
      #| primary     | normal  | reIndex        | { "reIndex": "test" } | |
      #| primary     | normal  | resetError     | { "resetError": 1 } | |
      #| primary     | normal  | serverStatus   | { "serverStatus": "test", "scale": 1 } | |
      #| primary     | admin   | setParameter   | { "setParameter": 1, "logLevel": 0 } | |
      #| primary     | admin   | top            | { "top": 1 } | |
      #| primary     | normal  | update         | { "update": "test", "updates": [{"q": {"a": 1}, "u": {"a": 2}}] } | |
      # pending - createIndexes dropIndexes
      # deprecated since version 2.6 - text cursorInfo

  Scenario: Primary Preferred Cursor Get More Continuity
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I query with read-preference PRIMARY_PREFERRED and batch size 2
    And I get 2 docs
    Then the get succeeds
    When I stop the arbiter
    And I stop the primary
    And I get 2 docs
    Then the get fails

  Scenario: Secondary Cursor Get More Continuity
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I query with read-preference SECONDARY and batch size 2
    And I get 2 docs
    Then the get succeeds
    When I stop the arbiter
    And I stop the primary
    And I track server status on secondaries
    And I get 2 docs
    Then the get succeeds
    And the getmore occurs on the secondary

  Scenario: Secondary Kill Cursors Continuity
    Given a replica set with preset arbiter
    And some documents written to all data-bearing members
    When I query with read-preference SECONDARY and batch size 2
    And I get 2 docs
    Then the get succeeds
    When I stop the arbiter
    And I stop the primary
    And I track server status on secondaries
    And I close the cursor
    Then the close succeeds
    And the kill cursors occurs on the secondary

  Scenario: Node is unpinned upon change in read preference
    See https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst#note-on-pinning
    See https://github.com/mongodb/mongo-ruby-driver/blob/1.x-stable/test/replica_set/pinning_test.rb
    Given a replica set with preset arbiter
    When I track server status on all data members
    And I query with default read preference
    Then the query occurs on the primary
    When I track server status on all data members
    And I query with read-preference SECONDARY_PREFERRED
    Then the query occurs on the secondary
    When I track server status on all data members
    And I query with read-preference PRIMARY_PREFERRED
    Then the query occurs on the primary

  Scenario: Query Auto-retry with Primary Stop
    See https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst#requests-and-auto-retry
    Auto-retry - after primary stop, query succeeds without error/exception
    Given a replica set with preset arbiter
    And a document written to all data-bearing members
    And I query with read-preference PRIMARY_PREFERRED
    Then the query succeeds
    When I stop the primary
    And I query with read-preference PRIMARY_PREFERRED
    Then the query succeeds
