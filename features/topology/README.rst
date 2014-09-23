=========================================
MongoDB Driver Common Topology Test Suite
=========================================

This repository holds the Driver Common Topology Test Suite for MongoDB.
This is a suite of tests intended to be run with actual server topologies.
The suite checks feature compliance with specifications for MongoDB drivers.
The suite does not attempt exhaustive code coverage or compliance,
but should provide a reasonable balance between run time and feature testing.
We welcome improvements to the test suite.
This is work in progress.

This README file is in `reStructuredText`_ form and follows
the `MongoDB Documentation Style Guidelines <http://docs.mongodb.org/manual/meta/style-guide/>`_.


Building Documents
------------------

(@pending)
We intend to build a readable specification document that interpolates feature descriptions.

Generic Tests
=============

The significant majority of tests are generic and not topology dependent.
These tests should definitely be run against a standalone mongod server to test basic function,
but we want to expand this so that the generic tests are run with a replica set and sharded cluster.
At present most drivers instantiate a client that connects explicitly to localhost port 27017.
This is fine for basic function,
but it makes it difficult to run generic tests against other topology configurations
that we need to do for completeness and robustness.

The following modifications are recommended.

1. Generic tests should instantiate a client using MONGODB_URI rather than explicitly specifying localhost port 27017.
2. To cover the basic generic tests with the “standard” standalone mongod on localhost port 27017,
   invoke the tests with MONGODB_URI=’mongodb://localhost:27017’
3. Migrate to running the generic tests against the full spectrum of “basic” preset topology configurations
   provided by Mongo Orchestration.
   Run the full generic test suite with each of the following.
  1. servers/basic.json
  2. replica_sets/basic.json
  3. sharded_clusters/basic.json
4. A test harness script that enables easy testing against a topology configuration provided by Mongo Orchestration.
   This aids both testing and development.

Generic tests should be as comprehensive as possible without being dependent on topology configuration specifics.
The generic tests should include all basic driver functions including
authorization, SSL, max values / MongoDB API version, etc.
Comprehensive generic tests are important,
as they both maximize test coverage for the above spectrum of topology configurations
and also minimize the following configuration-dependent test suit.

Configuration Dependent Test Suite
==================================

The feature behavior is described in the Gherkin language.
While the reference implementation is in Ruby using Cucumber,
we expect that driver engineers will choose to implement these topology tests as they see fit.
Since Ruby is the primary implementation language for Cucumber,
using Cucumber to run the feature specifications is natural for Ruby.
Other languages may choose to manually implement the scenarios or step definitions.

References:
* Gherkin DSL <https://github.com/cucumber/cucumber/wiki/Gherkin>
* Cucumber <http://cukes.info/>

Pending Feature Descriptions
----------------------------

Incomplete but intended feature descriptions are marked `@pending`.

Feature descriptions to be added include the following.

1. Cursor get more continuity
  1. test with two secondaries
     1. get more fails with primary prefered and no primary and error is node unavailable
2. Pinning test
  1. 1000 reads with nearest should all go to the same node
     1. less attractive alternative - two secondaries, 1000 reads all go to the same secondary
3. Discovery test - discuss overlap with Topology Monitoring
  1. all nodes down, check that driver initializes but can’t read/write, start up nodes, and check function progressively.
  2. one seed
     1. primary
     2. secondary
     3. arbiter
4. Auto-Retry
   1. query (non-command) only (in Ruby driver)
      1. query with primary preferred
      2. stop primary
      3. query with primary preferred - should success without an error/exception
   2. also with mongos failover(?) connection test
   3. standalone connection test
      1. query succeeds
      2. restart node
      3. ensure node is accepting queries (using side connection)
      4. attempt to query using original connection
      5. query succeeds without error/exception

5. Hidden replica set members

Postponed Feature Descriptions
==============================

These feature tests are postponed and are not in the feature descriptions.

Ping Times
----------
Ping time is implementation dependent and private to the implementation,
so feature tests are postponed.

Wire Protocol
-------------
References:
* Wire Protocol - 10gen / specifications <https://github.com/10gen/specifications/blob/master/source/driver-wire-protocol.rst>
* Driver Wire Version Overlap Specification - 10gen / specifications <https://github.com/10gen/specifications/blob/master/source/driver-wire-version-overlap-check.rst>

Use the primary for write-related values and operations.
* Version
* Limits - Max Values

For adequate testing, this requires a mixed server-version replica-set topology,
so it is postponed until support is available in mongo-orchestration.

Write Commands and Write Operations
-----------------------------------
Write operations are implemented via write commands for MongoDB version 2.6 or newer
and are implemented with the `old` wire-protocol for MongoDB version 2.4 or older.
Unit tests should be run with a matrix that incorporates server versions
and all topology categories including stand-alone server, replica set, and sharded cluster.

Testing beyond this requires a mixed server-version replica-set topology.
so mixed-server-version testing is postponed until support is available in mongo-orchestration.
In the meantime, run unit tests on the matrix.
