# language: en
# see serialize.feature; the two should be kept in sync
# as much as is possible/makes sense
@bson
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

  Scenario Outline: Deserialize simple BSON values
    Given a BSON value <hex_bytes>
    When I deserialize the value
    Then the result should be <value>
    And the result should have type <value_type>

   # copied from serialize.feature
    Examples:
      | value_type | value                    |                hex_bytes |
      | double     | 3.1459                   |         26e4839ecd2a0940 |
      | string     | test                     |       050000007465737400 |
      | object_id  | 50d3409d82cb8a4fc7000001 | 50d3409d82cb8a4fc7000001 |
      | boolean    | false                    |                       00 |
      | boolean     | true                     |                       01 |
      | datetime   | 946702800                |         8054e26bdc000000 |
      | regex      | regex                    |           72656765780000 |
      | symbol     | symbol                   |   0700000073796d626f6c00 |
      | int64      | 2147483648               |         0000008000000000 |
      | int32      | 12345                    |                 39300000 |

  # adapted from serialize.feature
  Scenario: Deserialize hash value
    Given the following BSON document:
    | bson_type | e_name | value              |
    |        01 | double | 1f85eb51b81e0940   |
    |        02 | string | 050000007465737400 |
    |        10 | int32  | d2040000           |
    When I deserialize the value
    Then the result should be the hash:
    | key    | value_type | value |
    | double | double     | 3.14  |
    | string | string     | test  |
    | int32  | int32      | 1234  |

    # adapted from serialize.feature
    Scenario: Deserialize array value
      Given the following BSON document:
      | bson_type | e_name | value              |
      | 01        | 0      | 1f85eb51b81e0940   |
      | 02        | 1      | 050000007465737400 |
      | 10        | 2      | d2040000           |
      When I deserialize the value
      Then the result should be the array:
      | value_type | value |
      | double     | 3.14  |
      | string     | test  |
      | int32      | 1234  |

      # adapted from serialize.feature
      Scenario Outline: Deserialize binary values
        Given a BSON value <hex_bytes>
        When I serialize the value
        Then the result should be <value>
        And the result should have type <binary_type>

        Examples:
        | value | binary_type | hex_bytes                   |
        | data  | generic     | 040000000064617461          |
        | data  | function    | 040000000164617461          |
        | data  | old         | 08000000020400000064617461  |
        | data  | uuid_old    | 040000000364617461          |
        | data  | uuid        | 040000000464617461          |
        | data  | md5         | 040000000564617461          |
        | data  | user        | 040000008064617461          |


      Scenario: Test serialized code execution
        Given a code value "function f(){return (1 + 2);} f()"
        When I serialize the value
        And I run the serialized code
        Then the code should return 3

      Scenario: Test code execution with scope
        Given a code value "function f(){return (1 + a);} f()" with scope {:a => 1}
        When I serialize the value
        And I run the serialized code
        Then the code should return 2
