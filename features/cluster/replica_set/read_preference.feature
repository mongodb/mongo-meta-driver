Feature: Read Preference
    In order to ensure I can route reads to the appropriate member
    As a driver author
    I want the driver to correctly route requests

    Scenario: Read Primary
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference PRIMARY
        Then the read occurs on the primary
        When there is no primary
        And I read with read-preference PRIMARY
        Then the read fails

    Scenario: Read Primary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference PRIMARY_PREFERRED
        Then the read occurs on the primary
        When there is no primary
        And I read with read-preference PRIMARY_PREFERRED
        Then the read succeeds

    Scenario: Read Secondary
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference SECONDARY
        Then the read occurs on the secondary
        When there are no secondaries
        And I read with read-preference SECONDARY
        Then the read fails

    Scenario: Read Secondary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference SECONDARY_PREFERRED
        Then the read occurs on the secondary
        When there are no secondaries
        And I read with read-preference SECONDARY_PREFERRED
        Then the read succeeds

    Scenario: Read With Nearest
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference NEAREST
        Then the read succeeds

    Scenario: Read Primary With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference PRIMARY and a tag set
        Then the read fails with error "PRIMARY cannot be combined with tags"

    Scenario: Read Primary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference PRIMARY_PREFERRED and a tag set
        Then the read occurs on the primary
        When there is no primary
        And I read with read-preference PRIMARY_PREFERRED and a matching tag set
        Then the read occurs on a matching secondary
        When I read with read-preference PRIMARY_PREFERRED and a non-matching tag set
        Then the read fails with error "No replica set member available for query with ReadPreference PRIMARY_PREFERRED and tags <tags>"

    Scenario: Read Secondary With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference SECONDARY and a secondary-matching tag set
        Then the read occurs on a matching secondary
        When I read with read-preference SECONDARY and a non-secondary-matching tag set
        Then the read fails with error "No replica set member available for query with ReadPreference SECONDARY and tags <tags>"

    Scenario: Read Secondary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference SECONDARY_PREFERRED and a secondary-matching tag set
        Then the read occurs on a matching secondary
        When I read with read-preference SECONDARY_PREFERRED and a non-secondary-matching tag set
        Then the read occurs on the primary

    Scenario: Read Nearest With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I read with read-preference NEAREST and a primary-matching tag set
        Then the read occurs on the primary
        When I read with read-preference NEAREST and a secondary-matching tag set
        Then the read occurs on a matching secondary
        When I read with read-preference NEAREST and a non-matching tag set
        Then the read fails with error "No replica set member available for query with ReadPreference NEAREST and tags <tags>"

    Scenario: Secondary OK Commands
        Given an arbiter replica set
        And some documents written to all data-bearing members
        And the following commands:
            | collStats                 |
            | count                     |
            | dbStats                   |
            | distinct                  |
            | geoNear                   |
            | geoSearch                 |
            | geoWalk                   |
            | group                     |
            | isMaster                  |
            | parallelCollectionScan    |
        When I run each of the commands with read-preference SECONDARY
        Then the command occurs on a secondary

    Scenario: MapReduce without inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform an inline map reduce with read-preference SECONDARY
        Then the command occurs on a primany

    Scenario: MapReduce with inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform an inline map reduce with read-preference SECONDARY
        Then the command occurs on a secondary

    Scenario: Aggregate with $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform aggregation with $out with read-preference SECONDARY
        Then the command occurs on a primany

    Scenario: Aggregate without $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform aggregation without $out with read-preference SECONDARY
        Then the command occurs on a secondary

    Scenario: Primary Only Commands
        Review - is this needed?

    Scenario: Node State Changes
        (pending)
        kill_cursors to appropriate node
        cursor continuity through node state transition

    Scenario: Node is unpinned upon change in read preference
        Given a replica set with more than 1 member
        When I read a document with the default read preference
        Then the read occurs on the primary
        When I read a document with the read preference SECONDARY_PREFERRED
        Then the read occurs on the secondary
        When I read a document with the read preference PRIMARY_PREFERRED
        Then the read occurs on the primary

