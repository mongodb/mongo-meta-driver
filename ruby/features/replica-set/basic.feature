Feature: Simply connections

  Background:
    Given all ReplicaSets has removed

  Scenario: Connect to ReplicaSet with three members
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_3m",
      "members":
      [
        { "procParams": { "port": 1024  }},
        { "procParams": { "port": 1025  }},
        { "procParams": { "port": 1026  }}
      ]
    }
    """
    And driver is connected to "mongodb://localhost:1024,localhost:1025,localhost:1026/?replicaSet=test_3m"
    Then opened connection has primary host
    And opened connection has "2" secondaries hosts

  Scenario: Connect to ReplicaSet with hidden members
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_hidden",
      "members":
      [
        { "procParams": { "port": 1027 }},
        { "procParams": { "port": 1028 }},
        { "procParams": { "port": 1029 }, "rsParams": {"hidden":true, "priority":0}},
        { "procParams": { "port": 1030 }, "rsParams": {"hidden":true, "priority":0}}
      ]
    }
    """
    And driver is connected to "mongodb://localhost:1027,localhost:1028/?replicaSet=test_hidden"
    Then opened connection has primary host
    And opened connection has "1" secondaries hosts
    And opened connection has "2" hidden hosts

  Scenario: Connect to ReplicaSet with arbiter
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_arbiter",
      "members":
      [
        { "procParams": { "port": 1031 }},
        { "procParams": { "port": 1032 }},
        { "procParams": { "port": 1033 }},
        { "procParams": { "port": 1034 }},
        { "procParams": { "port": 1035 }, "rsParams":{"arbiterOnly":true}},
        { "procParams": { "port": 1036 }, "rsParams":{"arbiterOnly":true}}
      ]
    }
    """
    And driver is connected to "mongodb://localhost:1031,localhost:1032,localhost:1033,localhost:1034/?replicaSet=test_arbiter"
    Then opened connection has primary host
    And opened connection has "3" secondaries hosts
    And opened connection has "2" arbiters hosts