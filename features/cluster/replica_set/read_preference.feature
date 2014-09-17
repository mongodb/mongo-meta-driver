Feature: Read Preference
    In order to ensure I can route reads to the appropriate member
    As a driver author
    I want the driver to correctly route requests

    Scenario: Read Primary
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference PRIMARY
        Then the read occurs on the primary
        When there is no primary
        And I read with read-preference PRIMARY
        Then the read fails

    Scenario: Read Primary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference PRIMARY_PREFERRED
        Then the read occurs on the primary
        When there is no primary
        And I read with read-preference PRIMARY_PREFERRED
        Then the read succeeds

    Scenario: Read Secondary
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference SECONDARY
        Then the read occurs on a secondary
        When there are no secondaries
        When I read with read-preference SECONDARY
        Then the read fails

    Scenario: Read Secondary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference SECONDARY_PREFERRED
        Then the read occurs on a secondary
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
        When I read with read-preference PRIMARY and tag sets [{"ordinal": "one"}, {"dc": "ny"}]
        Then the read fails with error "PRIMARY cannot be combined with tags"

    @pending
    Scenario: Read Primary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}, {"dc": "pa"}]
        Then the read occurs on the primary
        When there is no primary
        When I track opcounters
        And I read with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}]
        Then the read occurs on a secondary
        When I read with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "three"}, {"dc": "na"}]
        Then the read fails with error "No replica set member available for query with read preference matching mode PRIMARY_PREFERRED and tags matching <tags sets>."

    Scenario: Read Secondary With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference SECONDARY and tag sets [{"ordinal": "two"}]
        Then the read occurs on a secondary
        When I read with read-preference SECONDARY and tag sets [{"ordinal": "one"}]
        Then the read fails with error "No replica set member available for query with read preference matching mode SECONDARY and tags matching <tags sets>."

    Scenario: Read Secondary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "two"}]
        Then the read occurs on a secondary
        When I track opcounters
        And I read with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "three"}]
        Then the read occurs on the primary

    @driver_broken
    Scenario: Read Nearest With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I read with read-preference NEAREST and tag sets [{"ordinal": "one"}]
        Then the read occurs on the primary
        When I track opcounters
        And I read with read-preference NEAREST and tag sets [{"ordinal": "two"}]
        Then the read occurs on a secondary
        When I read with read-preference NEAREST and tag sets [{"ordinal": "three"}]
        Then the read fails with error "No replica set member available for query with read preference matching mode NEAREST and tags matching <tags sets>"

    @pending
    Scenario Outline: Secondary OK Commands
        Given an arbiter replica set
        And a document written to all data-bearing members
        When I track opcounters
        And I run a <name> command with read-preference SECONDARY and with example <example>
        Then the command occurs on a secondary
        Examples:
          | name      | example |
          | collStats | {"collStats": "test" } |
          | count     | {"count": "test"} |
          | dbStats   | {"dbStats": 1} |
          | distinct  | {"distinct": "test", "key": "a" } |
          | group     | {"group": {"ns": "test", "key": "a", "$reduce": "function ( curr, result ) { }", "initial": {}}} |
          | isMaster  | {"isMaster": 1} |
          | parallelCollectionScan | {"parallelCollectionScan": "test", "numCursors": 2} |

    @pending
    Scenario: Secondary OK Geonear
        Given an arbiter replica set
        And some geo documents written to all data-bearing members
        And a geo 2d index
        When I track opcounters
        And I run a geonear command with read-preference SECONDARY
        Then the command occurs on a secondary

    @pending
    Scenario: Secondary OK MapReduce with inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I track opcounters
        And I run a map-reduce with field out value inline true and with read-preference SECONDARY
        Then the command occurs on a secondary

    @pending
    Scenario: Primary Reroute MapReduce without inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I track opcounters
        And I run a map-reduce with field out value other than inline and with read-preference SECONDARY
        Then the command occurs on the primary

    @pending
    Scenario: Secondary OK Aggregate without $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I track opcounters
        And I run an aggregate without $out and with read-preference SECONDARY
        Then the command occurs on a secondary

    @pending
    Scenario: Primary Reroute Aggregate with $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I track opcounters
        And I run an aggregate with $out and with read-preference SECONDARY
        Then the command occurs on the primary

    @pending
    Scenario: Primary Only Commands
        #Review - is this needed?

    @pending
    Scenario: Node State Changes
        #kill_cursors to appropriate node
        #cursor continuity through node state transition

    @pending
    Scenario: Node is unpinned upon change in read preference
        Given a replica set with more than 1 member
        When I read a document with the default read preference
        Then the read occurs on the primary
        When I read a document with the read preference SECONDARY_PREFERRED
        Then the read occurs on the secondary
        When I read a document with the read preference PRIMARY_PREFERRED
        Then the read occurs on the primary
