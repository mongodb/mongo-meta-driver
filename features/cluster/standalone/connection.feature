Feature: Standalone Connection
    In order to ensure the driver remains usable in the face of failures
    As a driver author
    I want the driver to recover in the event of failures

    Scenario: Server is stopped and started
        Given a cluster in the standalone server configuration
        When I insert a document
        Then the insert succeeds
        When I stop the server
        And I insert a document
        Then the insert fails
        When I start the server
        And I insert a document
        Then the insert succeeds

    Scenario: Server is restarted
        Given a cluster in the standalone server configuration
        When I insert a document
        Then the insert succeeds
        When I restart the server
        And I insert a document with retries
        Then the insert succeeds
