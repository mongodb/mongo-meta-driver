Feature: Read Preference
    In order to ensure I can route reads to the appropriate member
    As a driver author
    I want the driver to correctly route requests

    Scenario: Read Primary
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference PRIMARY
        When I read with opcounter tracking
        Then the read occurs on the primary
        When there is no primary
        And I read
        Then the read fails

    Scenario: Read Primary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference PRIMARY_PREFERRED
        When I read with opcounter tracking
        Then the read occurs on the primary
        When there is no primary
        And I read
        Then the read succeeds

    Scenario: Read Secondary
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference SECONDARY
        When I read with opcounter tracking
        Then the read occurs on a secondary
        When there are no secondaries
        When I read
        Then the read fails

    Scenario: Read Secondary Preferred
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference SECONDARY_PREFERRED
        When I read with opcounter tracking
        Then the read occurs on a secondary
        When there are no secondaries
        And I read
        Then the read succeeds

    Scenario: Read With Nearest
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference NEAREST
        When I read
        Then the read succeeds

    Scenario: Read Primary With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference PRIMARY and tag sets [{"ordinal": "one"}, {"dc": "ny"}]
        When I read
        Then the read fails with error "PRIMARY cannot be combined with tags"

    Scenario: Read Primary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}, {"dc": "pa"}]
        When I read with opcounter tracking
        Then the read occurs on the primary
        When there is no primary
        Given a client with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "two"}]
        When I read with opcounter tracking
        Then the read occurs on a secondary
        Given a client with read-preference PRIMARY_PREFERRED and tag sets [{"ordinal": "three"}, {"dc": "na"}]
        When I read
        Then the read fails with error "No replica set member available for query with read preference matching mode primary_preferred and tags matching <tags sets>."

    Scenario: Read Secondary With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference SECONDARY and tag sets [{"ordinal": "two"}]
        When I read with opcounter tracking
        Then the read occurs on a secondary
        Given a client with read-preference SECONDARY and tag sets [{"ordinal": "one"}]
        When I read
        Then the read fails with error "No replica set member available for query with read preference matching mode secondary and tags matching <tags sets>."

    Scenario: Read Secondary Preferred With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "two"}]
        When I read with opcounter tracking
        Then the read occurs on a secondary
        Given a client with read-preference SECONDARY_PREFERRED and tag sets [{"ordinal": "three"}]
        When I read with opcounter tracking
        Then the read occurs on the primary

    Scenario: Read Nearest With Tag Sets
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference NEAREST and tag sets [{"ordinal": "one"}]
        When I read with opcounter tracking
        Then the read occurs on the primary
        Given a client with read-preference NEAREST and tag sets [{"ordinal": "two"}]
        When I read with opcounter tracking
        Then the read occurs on a secondary
        Given a client with read-preference NEAREST and tag sets [{"ordinal": "three"}]
        When I read
        Then the read fails with error "No replica set member available for query with read preference matching mode nearest and tags matching <tags sets>"

    @solo
    Scenario Outline: Secondary OK Commands
        Given an arbiter replica set
        And a document written to all data-bearing members
        And a client with read-preference SECONDARY
        When I run with opcounter tracking a <name> command with example <example>
        Then the command occurs on a secondary
        Examples:
          | name      | example |
          | aggregate | {"aggregate": "test", "pipeline": [{"$group": {"_id": null, "count": {"$sum": 1}}}]} |
          | collStats | {"collStats": "test" } |
          | count     | {"count": "test"} |
          | dbStats   | {"dbStats": 1} |
          | distinct  | {"distinct": "test", "key": "a" } |
          | group     | {"group": {"ns": "test", "key": "a", "$reduce": "function ( curr, result ) { }", "initial": {}}} |
          | isMaster  | {"isMaster": 1} |
          | mapReduce | {"mapReduce": "test", "map": "function(){emit('a',this.a)}", "reduce": "function(key,values){return Array.sum(values)}", "out": {"inline": 1}} |
          | parallelCollectionScan | {"parallelCollectionScan": "test", "numCursors": 2} |

    @pending
    Scenario: MapReduce without inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform an inline map reduce with read-preference SECONDARY
        Then the command occurs on a primany

    @pending
    Scenario: MapReduce with inline
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform an inline map reduce with read-preference SECONDARY
        Then the command occurs on a secondary

    @pending
    Scenario: Aggregate with $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform aggregation with $out with read-preference SECONDARY
        Then the command occurs on a primany

    @pending
    Scenario: Aggregate without $out
        Given an arbiter replica set
        And some documents written to all data-bearing members
        When I perform aggregation without $out with read-preference SECONDARY
        Then the command occurs on a secondary

    @pending
    Scenario: Primary Only Commands
        Review - is this needed?

    @pending
    Scenario: Node State Changes
        kill_cursors to appropriate node
        cursor continuity through node state transition

    @pending
    Scenario: Node is unpinned upon change in read preference
        Given a replica set with more than 1 member
        When I read a document with the default read preference
        Then the read occurs on the primary
        When I read a document with the read preference SECONDARY_PREFERRED
        Then the read occurs on the secondary
        When I read a document with the read preference PRIMARY_PREFERRED
        Then the read occurs on the primary

