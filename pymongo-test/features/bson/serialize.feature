# language: en
# see deserialize.feature; the two should be kept in sync
# as much as is possible/makes sense
@mongo @bson
Feature: Serialize Elements 
  As a user of MongoDB
  In order to store data in the database
  The driver needs to serialize BSON elements

  Scenario Outline: Serialize BSON types
    Given a <value_type> value
    Then the value should correspond to the BSON type <bson_type>

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
   #   | symbol       |        0E |
      | code_w_scope |        0F |
      | int32        |        10 |
      | timestamp    |        11 |
      | int64        |        12 |
      | min_key      |        FF |
      | max_key      |        7F |

  # CLARIFY
  Scenario Outline: Serialize documents containing simple BSON values
    Given a <value_type> value <value>
    When I serialize the value
    Then the result should be <hex_bytes>

    Examples:
      | value_type | value                    | hex_bytes                                |
      | double     | 3.1459                   | 10000000016b0026e4839ecd2a094000         |
      | string     | test                     | 11000000026b0005000000746573740000       |
      | object_id  | 50d3409d82cb8a4fc7000001 | 14000000076b0050d3409d82cb8a4fc700000100 |
      | boolean    | false                    | 09000000086b000000                       |
      | boolean    | true                     | 09000000086b000100                       |
      | datetime   | 946702800                | 10000000096b008054e26bdc00000000         | 
      | regex      | regex                    | 0f0000000b6b007265676578000000           | 
      #| symbol     | symbol                   | 130000000e6b000700000073796d626f6c0000   |
      | int32      | 12345                    | 0c000000106b003930000000                 |
      | int64      | 2147483648               | 10000000126b00000000800000000000         |

  Scenario: Serialize hash value
    Given a hash with the following items:
      | key    | value_type | value |
      | double | double     | 3.14  |
      | string | string     | test  |
      | int32  | int32      | 1234  |
    When I serialize the value
    Then the result should be the BSON document:
      | bson_type | e_name | value              |
      | 01        | double | 1f85eb51b81e0940   |
      | 02        | string | 050000007465737400 |
      | 10        | int32  | d2040000           |

  Scenario: Serialize array value
    Given a array with the following items:
      | value_type | value |
      | double     | 3.14  |
      | string     | test  |
      | int32      | 1234  |
    When I serialize the value
    Then the result should be the BSON document:
      | bson_type | e_name | value              |
      | 01        | 0      | 1f85eb51b81e0940   |
      | 02        | 1      | 050000007465737400 |
      | 10        | 2      | d2040000           |

  Scenario Outline: Serialize binary values
    Given a binary value <value> with binary type <binary_type>
    When I serialize the value
    Then the result should be <hex_bytes>

    Examples:
      | value | binary_type | hex_bytes                                  |
      | data  | generic     | 11000000056b0004000000006461746100         |
      | data  | function    | 11000000056b0004000000016461746100         |
      | data  | old         | 15000000056b000800000002040000006461746100 |
      | data  | uuid_old    | 11000000056b0004000000036461746100         |
      | data  | uuid        | 11000000056b0004000000046461746100         |
      | data  | md5         | 11000000056b0004000000056461746100         |
      | data  | user        | 11000000056b0004000000806461746100         |

  Scenario Outline: Serialize code values
    Given a code value "<code>" with scope <scope>
    When I serialize the value
    Then the result should be <hex_bytes>

    Examples:
      | code         | scope        | hex_bytes                                                                          |
      | function(){} |              | 190000000d6b000d00000066756e6374696f6e28297b7d0000                                 |
      | function(){} | {"a" : 1}    | 290000000f6b00210000000d00000066756e6374696f6e28297b7d000c000000106100010000000000 |




