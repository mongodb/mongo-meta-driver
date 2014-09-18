Feature: Write Concern

    Scenario: Replicated Write Operations Timeout with W Failure
        Given a basic replica set
        When I insert a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
        Then the write operation fails write concern
        When I update a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
        Then the write operation fails write concern
        When I delete a document with the write concern { “w”: <nodes + 1>, “timeout”: 1}
        Then the write operation fails write concern
