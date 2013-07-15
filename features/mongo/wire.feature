# language: en
# NB: example messages are taken from the production Ruby driver.
# I have tried to double-check some against the Python driver as well.
@mongo @wire
Feature: Creating commands for database
  As a user of MongoDB
  In order to communicate with MongoDB
  I must issue commands to MongoDB
  And these commands must conform to the MongoDB Wire Protocol specification.

  Background:
    Given my request will have an ID of 1234
    And I am using the collection "mydb.mycoll"

  Scenario Outline: Generating OP_UPDATE messages (updating documents)
    Given I am generating an OP_UPDATE message
    And I am selecting fields to update by the document <selector>
    And I am updating by the document <update>
    And I am <upsert> doing an upsert
    And I am <multi_update> doing a multi update
    When I generate the wire protocol message for this request
    Then the generated message should match <message>

    Examples:
      | selector             | update     | upsert | multi_update | message                                                                                                                                |
      | {'a' => 1}           | {'a' => 2} | not    |              | 3c000000d204000000000000d1070000000000006d7964622e6d79636f6c6c00020000000c00000010610001000000000c0000001061000200000000               |
      | {'a' => 2, 'b' => 3} | {'b' => 4} |        | not          | 43000000d204000000000000d1070000000000006d7964622e6d79636f6c6c0001000000130000001061000200000010620003000000000c0000001062000400000000 |

  Scenario: Generating an OP_INSERT message (inserting documents)
    Given I am generating an OP_INSERT message
    And I am not doing a continue on error
    And I am inserting the documents:
      | doc                                     |
      | {'a' => 1, 'b' => 2}                    |
      | {'a' => 1, 'g' => {'d' => 1}, 'b' => 2} |
      | {'c' => 'c'}                            |
    When I generate the wire protocol message for this request
    Then the generated message should match 63000000d204000000000000d2070000000000006d7964622e6d79636f6c6c001300000010610001000000106200020000000022000000106100010000000367000c000000106400010000000010620002000000000e00000002630002000000630000

  Scenario: Generating an OP_INSERT message with continue on error
    Given I am generating an OP_INSERT message
    And I am doing a continue on error
    And I am inserting the documents:
      | doc                  |
      | {'a' => 1, 'b' => 2} |
    When I generate the wire protocol message for this request
    Then the generated message should match 33000000d204000000000000d2070000010000006d7964622e6d79636f6c6c0013000000106100010000001062000200000000

  Scenario Outline: Generating OP_QUERY messages (querying for documents)
    Given I am generating an OP_QUERY message
    And I am skipping <num_to_skip> results
    And I am returning <num_to_return> results
    And I am querying by the document <query>
    And I am selecting fields to return by the document <return_selector>
    And I am <tailable_cursor> doing a tailable cursor query
    And I am <slave_ok> permitting querying of a replica slave
    And I am <no_cursor_timeout> permitting idle cursors to persist
    And I am <await_data> permitting cursors to block and wait for more data
    And I am <exhaust> pulling all queried data at once
    And I am <partial> permitting partial results if a shard is down
    When I generate the wire protocol message for this request
    Then the generated message should match <message>

    Examples:
      | num_to_skip | num_to_return | query                  | return_selector | tailable_cursor | slave_ok | no_cursor_timeout | await_data | exhaust | partial | message                                                                                                                                        |
      | 3           | 3             | {'a' => 1, 'b' => 2}   | {'c' => 1}      |                 | not      | not               |            | not     | not     | 47000000d204000000000000d4070000220000006d7964622e6d79636f6c6c000300000003000000130000001061000100000010620002000000000c0000001063000100000000 |
      | 0           | 10            | {'b' => {'$lte' => 4}} |                 | not             |          |                   | not        |         |         | 3f000000d204000000000000d4070000d40000006d7964622e6d79636f6c6c00000000000a000000170000000362000f00000010246c746500040000000000                 |

  Scenario Outline: Generating OP_GET_MORE messages (requesting more documents from an existing cursor)
    Given I am generating an OP_GET_MORE message
    And I am returning <num_to_return> results
    And I am requesting results for the cursor with id <cursor_id>
    When I generate the wire protocol message for this request
    Then the generated message should match <message>

    Examples:
      | num_to_return | cursor_id | message                                                                                  |
      | 10            | 5         | 2c000000d204000000000000d5070000000000006d7964622e6d79636f6c6c000a0000000500000000000000 |

  Scenario Outline: Generating OP_DELETE messages (deleting documents)
    Given I am generating an OP_DELETE message
    And I am selecting documents to delete by the document <selector>
    And I am <multiple_remove> permitting removal of multiple documents
    When I generate the wire protocol message for this request
    Then the generated message should match <message>

    Examples:
      | selector   | multiple_remove | message                                                                                          |
      | {'a' => 1} | not             | 30000000d204000000000000d6070000000000006d7964622e6d79636f6c6c00010000000c0000001061000100000000 |

  Scenario: Generating an OP_KILL_CURSORS message (request closing of active cursors)
    Given I am generating an OP_KILL_CURSORS message
    And I am deleting the cursors with ids:
      | cursor_id     |
      | 10001         |
      | 20002         |
      | 30003         |
      | 1000000000001 |
    When I generate the wire protocol message for this request
    Then the generated message should match 38000000d204000000000000d707000000000000040000001127000000000000224e00000000000033750000000000000110a5d4e8000000

  Scenario Outline: Parsing an OP_REPLY message (response from server)
    Given MongoDB has responded with the OP_REPLY message <message>
    When I parse the message
    Then I should learn that the message has identifier <msg_id>
    And I should learn that the message is in response to the request with identifier <response_to>
    And the opcode should correspond to OP_REPLY
    And I should learn that the cursor ID to get more results is <cursor_id>
    And I should learn that this reply is starting from <start_from> results into the cursor
    And I should learn that <num_returned> documents are being returned
    And I should learn that the requested cursor is <cursor_found> found
    And I should learn that the query is <query_success> successful
    And I should learn that the sharding configuration is <shard_config_stale> outdated
    And I should learn that the server is <await_capable> able to support the await_data query parameter
    And the message should contain the documents <docs>

    Examples:
      | msg_id | response_to | cursor_id     | start_from | num_returned | cursor_found | query_success | shard_config_stale | await_capable | docs                                                                                                   | message                                                                                                                                                                                                                                                                    |
      | 4567   | 1234        | 12345         | 0          | 2            |              |               |                    | not           | [{'a'=>1}, {'b'=>2, 'd'=>{'0'=>1}}]                                                                    | 4b000000d7110000d20400000100000004000000393000000000000000000000020000000c00000010610001000000001b000000106200020000000364000c000000103000010000000000                                                                                                                     |
      | 5678   | 3210        | 1000000000001 | 5          | 3            |              |               | not                |               | [{'1'=>2},{'2'=>3},{'3'=>2, '2'=> "hello, world"}]                                                     | 5c0000002e1600008a0c000001000000080000000110a5d4e800000005000000030000000c00000010310002000000000c000000103200030000000020000000103300020000000232000d00000068656c6c6f2c20776f726c640000                                                                                   |
      | 10     | 42          | 12345         | 10         | 0            | not          |               | not                |               | []                                                                                                     | 240000000a0000002a000000010000000900000039300000000000000a00000000000000                                                                                                                                                                                                   |
      | 59     | 61          | 6543210       | 7          | 1            |              | not           | not                |               | [{'$err'=>"can't map file memory - mongo requires 64 bit build for larger datasets", "code" => 10084}] | 850000003b0000003d000000010000000a0000006ad76300000000000700000001000000610000000224657272004800000063616e2774206d61702066696c65206d656d6f7279202d206d6f6e676f20726571756972657320363420626974206275696c6420666f72206c61726765722064617461736574730010636f6465006427000000 |

  Scenario: Unique message ID generation
    Given I have generated a message
    When I generate another message
    Then the two messages should not have the same request ID