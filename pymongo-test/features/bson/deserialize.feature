# language: en
# see serialize.feature; the two should be kept in sync
# as much as is possible/makes sense
@mongo @bson
Feature: Deserialize Elements
  As a user of MongoDB
  In order to retreive data from the database
  The driver needs to deserialize BSON elements

  Scenario Outline: Deserialize BSON types
    Given a BSON type <bson_type>
    Then the BSON type should correspond to the value type <value_type>

    # copied from serialize.feature
    Examples:
      | value_type   | bson_type |
      | double       |        01 |
      | string       |        02 |
      | document     |        03 |
      | array        |        04 |
      | binary       |        05 |
      | undefined    |        06 |
      | object_id    |        07 |
      | boolean      |        08 |
      | datetime     |        09 |
      | null         |        0A |
      | regex        |        0B |
      | db_pointer   |        0C |
      | code         |        0D |
      | symbol       |        0E |
      | code_w_scope |        0F |
      | int32        |        10 |
      | timestamp    |        11 |
      | int64        |        12 |
      | min_key      |        FF |
      | max_key      |        7F |

  # TODO: make this less unwieldy by using transforms?
  Scenario Outline: Deserialize singleton BSON objects
    Given an IO stream containing <hex_bytes>
    When I deserialize the stream
    Then the result should be the <type> value <value>

    Examples:
    | hex_bytes                                | type      | value                    |
    | 10000000016b0026e4839ecd2a094000         | double    | 3.1459                   |
    | 11000000026b0005000000746573740000       | string    | test                     |
    | 14000000076b0050d3409d82cb8a4fc700000100 | object_id | 50d3409d82cb8a4fc7000001 |
    | 09000000086b000000                       | boolean   | false                    |
    | 09000000086b000100                       | boolean   | true                     |
    | 10000000096b008054e26bdc00000000         | datetime  | 946702800                |
    | 0f0000000b6b007265676578000000           | regex     | regex                    |
 #   | 130000000e6b000700000073796d626f6c0000   | symbol    | symbol                   |
    | 10000000126b00000000800000000000         | int64     | 2147483648               |
    | 0c000000106b003930000000                 | int32     | 12345                    |

  Scenario: Deserialize hash value
    Given an IO stream containing 3100000001646f75626c65001f85eb51b81e094002737472696e670005000000746573740010696e74333200d204000000
    When I deserialize the stream
    Then the result should be the following hash:
      | key    | value_type | value |
      | double | double     | 3.14  |
      | string | string     | test  |
      | int32  | int32      | 1234  |

  # TODO arrays
  Scenario: Deserialize array
    Given an IO stream containing 2b000000046b00230000000130001f85eb51b81e0940023100050000007465737400103200d20400000000
    When I deserialize the stream
    Then the result should be a document mapping k to the following array:
      | value_type | value |
      | double     | 3.14  |
      | string     | test  |
      | int32      | 1234  |

  # adapted from serialize.feature
  Scenario Outline: Deserialize binary values
    Given an IO stream containing <hex_bytes>
    When I deserialize the stream
    Then the result should be the binary value <value> with binary type <binary_type>

# some of these don't work for some reason with pymongo. unsure if it's a bug.
    Examples:
    | value | binary_type | hex_bytes                                  |
    | data  | generic     | 11000000056b0004000000006461746100         |
    | data  | function    | 11000000056b0004000000016461746100         |
    | data  | old         | 15000000056b000800000002040000006461746100 |
# TODO - these encoded UUIDs are invalid. We should replace them with ones that are so we can test this scenario fully.
#        | data  | uuid_old    | 11000000056b0004000000036461746100         |
#        | data  | uuid        | 11000000056b0004000000046461746100         |
    | data  | md5         | 11000000056b0004000000056461746100         |
    | data  | user        | 11000000056b0004000000806461746100         |


  Scenario Outline: Deserialize code
    Given an IO stream containing <hex_bytes>
    When I deserialize the stream
    Then the result should be a code value "<code>" with scope <scope>

    Examples:
    | hex_bytes                                                                          | code         | scope      |
    | 190000000d6b000d00000066756e6374696f6e28297b7d0000                                 | function(){} |            |
    | 290000000f6b00210000000d00000066756e6374696f6e28297b7d000c000000106100010000000000 | function(){} | {"a" : 1}  |
