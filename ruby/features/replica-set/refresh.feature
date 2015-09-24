Feature: Refresh connection

  Background:
    Given all ReplicaSets has removed

  Scenario: Autorefresh for append secondary node
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_append",
      "members":
      [
        { "procParams": { "port": 1024 }},
        { "procParams": { "port": 1025 }},
        { "procParams": { "port": 1026 }}
      ]
    }
    """
    And driver is connected to "mongodb://localhost:1024,localhost:1025,localhost:1026/?replicaSet=test_append"
    And opened connection has primary host
    And opened connection has "2" secondaries hosts
    Then following node is append to ReplicaSet
    """
    { "procParams": {"port": 1027} }
    """
    And opened connection has primary host
    And opened connection has "3" secondaries hosts

  @debug
  Scenario: Autorefresh for down primary node
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_drop",
      "members":
      [
        { "procParams": { "port": 1024 }},
        { "procParams": { "port": 1025 }},
        { "procParams": { "port": 1026 }}
      ]
    }
    """
    And driver is connected to "mongodb://localhost:1024,localhost:1025,localhost:1026/?replicaSet=test_drop"
    And opened connection has primary host
    And opened connection has "2" secondaries hosts
    Then ReplicaSet's primary node is down
    And opened connection has primary host
    And opened connection has "1" secondaries hosts