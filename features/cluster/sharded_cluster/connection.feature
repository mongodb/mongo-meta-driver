Feature:

    Scenario: mongos Router Failover - Failure and Recovery
        Given a basic sharded cluster with routers A and B
        When I insert a document
        Then the insert succeeds
        When I stop router A
        And I insert a document with retries
        Then the insert succeeds (eventually)
        When I stop router B
        And I insert a document
        Then the insert fails
        When I start router B
        And I insert a document
        Then the insert succeeds
        When I start router A
        And I insert a document
        Then the insert succeeds
        When I stop router B
        And I insert a document with retries
        Then the insert succeeds (eventually)

    Scenario: mongos Router Restart
        Given a basic sharded cluster with routers A and B
        When I insert a document
        Then the insert succeeds
        When I restart router A
        And I insert a document with retries
        Then the insert succeeds (eventually)
        When I restart router B
        And I insert a document with retries
        Then the insert succeeds (eventually)
