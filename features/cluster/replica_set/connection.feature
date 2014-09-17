Feature:

    Scenario: Primary Step Down
        Given a basic replica set
        When I insert a document
        Then the insert succeeds
        When I command the primary to step down
        And I insert a document with retries
        Then the insert succeeds

    @pending
    Scenario: Primary Failure

    @pending
    Scenario: Primary Recovery

    @pending
    Scenario: Primary Restart

    @pending
    Scenario: Secondary Failure

    @pending
    Scenario: Secondary Recovery

    @pending
    Scenario: Secondary Restart

