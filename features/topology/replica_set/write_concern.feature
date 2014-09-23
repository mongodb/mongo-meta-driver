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

Feature: Write Concern
  In order to support write concern that describes the guarantee that MongoDB provides when reporting on
    the result of a write operation
  As a driver author
  I want to verify that the driver correctly behaves according to documentation and specification
  http://docs.mongodb.org/manual/core/write-concern/
  https://github.com/mongodb/specifications/blob/master/source/server_write_commands.rst
  https://github.com/10gen/specifications/blob/master/source/driver-bulk-update.rst

  @pending
  @discuss
  Scenario: Write Operation with Write Concern
    # probably (can) only test that write concern is in write command or GLE

  @pending
  @discuss
  Scenario: Bulk Write with Write Concern
    # probably (can) only test that write concern is in write command or GLE

  Scenario: Replicated Write Operations Timeout with W Failure
    Given a replica set with preset arbiter
    When I insert a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the write operation fails write concern
    When I update a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the write operation fails write concern
    When I delete a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the write operation fails write concern

  @discuss
  Scenario: Replicated Bulk Write Operation Timeout with W Failure
    Given a replica set with preset arbiter
    When I execute an ordered bulk write operation with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the bulk write operation fails
    And the result includes a write concern error
    When I remove all documents from the collection
    And I execute an unordered bulk write operation with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the bulk write operation fails
    And the result includes a write concern error
    When I remove all documents from the collection
    And I execute an ordered bulk write operation with a duplicate key and with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the bulk write operation fails
    And the result includes a write error
    And the result includes a write concern error
    When I remove all documents from the collection
    And I execute an unordered bulk write operation with a duplicate key and with the write concern { “w”: <nodes + 1>, “timeout”: 1}
    Then the bulk write operation fails
    And the result includes a write error
    And the result includes a write concern error


