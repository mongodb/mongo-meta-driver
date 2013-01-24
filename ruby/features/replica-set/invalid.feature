Feature: Invalid URI

  Background:
    Given all ReplicaSets has removed

  Scenario: Invalid ReplicaSet URI
    When driver throws exception when try connect to "mongodb://localhost:1,localhost:2,localhost:3/?replicaSet=test"

  Scenario: Connection to ReplicaSet with faulty ports
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_invalid",
      "members":
      [
        { "procParams": { "port": 1024  }},
        { "procParams": { "port": 1025  }}
      ]
    }
    """
    Then driver throws exception when try connect to "mongodb://localhost:1029,localhost:1024/?replicaSet=test_invalid"

  Scenario: Connection to ReplicaSet without Id in URI
    When ReplicaSet for following configuration is created
    """
    {
      "id": "test_invalid_two",
      "members":
      [
        { "procParams": { "port": 1024  }},
        { "procParams": { "port": 1025  }}
      ]
    }
    """
    Then driver throws exception when try connect to "mongodb://localhost:1024,localhost:1025"