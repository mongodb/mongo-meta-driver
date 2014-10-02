MongoDB Driver Common Topology Test Suite
=========================================

:Spec:
:Title: Common Topology Test Suite
:Author: Gary J\. Murakami
:Advisors: Tyler Brock
:Status: Draft
:Type: Standards
:Last Modified: October 2, 2014

.. contents::


Abstract
--------

This is the **Common Topology Test Suite** for MongoDB drivers.
The **goal** is to codify topology-related driver behavior into a common test suite.
The common test suite can be used by driver authors and maintainers to understand, implement and verify driver behavior.

The **approach** is to specify driver-behavior features in
the `Gherkin language <https://github.com/cucumber/cucumber/wiki/Gherkin>`_.
The *feature descriptions* are high-level *user stories* that are applicable
across the spectrum of MongoDB drivers and programming languages.
The *test suite* was condensed and refined from existing specification documents, driver tests, and experience.
References are included in the test suite.

The **result** is a comprehensive *test suite* of feature descriptions.
The feature descriptions can be combined with step definitions in an actual programming language
into tests for continuous integration.
Software tools like `Cucumber <http://cukes.info/>`_ can drive the tests or they can be coded manually.
A reference implementation has been completed for the
`Ruby 1.x driver <https://github.com/gjmurakami-10gen/mongo-ruby-driver/blob/1.x-mongo-orchestration/features/step_definitions/cluster_steps.rb>`_.

At present, the approximate statistics are:

* 7 features
  * 46 scenarios
    * 394 steps
      * 695 lines (Gherkin)
* 53 step definitions
  * 533 lines (Ruby reference implementation)
* mongo-orchestration wrapper
  * 254 lines (Ruby reference implementation)
  * 489 lines (Ruby reference RSpec tests)

The high-level **taxonomy** is as follows.

* `standalone <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/standalone>`_
  * `connection.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/standalone/connection.feature>`_
* `replica_set <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/replica_set>`_
  * `configuration.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/replica_set/configuration.feature>`_
  * `connection.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/replica_set/connection.feature>`_
  * `read_preference.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/replica_set/read_preference.feature>`_
  * `write_concern.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/replica_set/write_concern.feature>`_
* `sharded_cluster <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/sharded_cluster>`_
  * `configuration.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/sharded_cluster/configuration.feature>`_
  * `connection.feature <https://github.com/mongodb/mongo-meta-driver/blob/master/features/topology/sharded_cluster/connection.feature>`_

This specification document can be found online.

* `common-topology-test-suite.rst <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/common-topology-test-suite.rst>`_

This document file follows
the `MongoDB Documentation Style Guidelines <http://docs.mongodb.org/manual/meta/style-guide/>`_.
It is in `reStructuredText <http://docutils.sourceforge.net/rst.html>`_ form,
intended for `GitHub Markup <https://github.com/github/markup>`_.


Meta
----

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL
NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY", and
"OPTIONAL" in this document are to be interpreted as described in
`RFC 2119`_.

.. _RFC 2119: https://www.ietf.org/rfc/rfc2119.txt


Specification
-------------

Important note:

    For the feature specification,
    please see the section **Full Specification** below
    that is generated from the *test suite* feature description files.

This **Full Specification** is for behavior that depends on actual topology configurations and details,
features that are not specific to server topology should be covered elsewhere,
as in generic tests discussed below.

The suite does *not* attempt exhaustive code coverage or compliance,
however it is reasonably comprehensive for topology-dependent behavior
that is common across drivers and language independent.
Improvements to the test suite are welcome.
This is *work in progress* and some features and scenarios are pending.


Generic Tests
'''''''''''''

The significant majority of tests are generic and not topology dependent.
These tests should definitely be run against a standalone **mongod** server to test basic function,
but we want to expand this so that the generic unit tests can also be run with a replica set or sharded cluster.
At present most drivers instantiate a client that connects explicitly to localhost port 27017.
This is fine for basic function,
but it makes it difficult to run generic tests against other topology configurations.
We need to do this for completeness and robustness.

The following modifications are recommended.

1. Generic tests should instantiate a client using ``MONGODB_URI`` rather than explicitly specifying localhost port 27017.
2. To cover the basic generic tests with the “standard” standalone **mongod** on localhost port 27017,
   invoke the tests with ``MONGODB_URI=’mongodb://localhost:27017’``
3. Migrate to running the generic tests against the full spectrum of “basic” preset topology configurations
   provided by `Mongo Orchestration <https://github.com/mongodb/mongo-orchestration>`_.
   Run the full generic test suite with each of the following.

   1. servers/basic.json
   2. replica_sets/basic.json
   3. sharded_clusters/basic.json

4. A test harness script that enables easy testing against a topology configuration provided by `Mongo Orchestration <https://github.com/mongodb/mongo-orchestration>`_.
   This aids both testing and development.

Generic tests should be as comprehensive as possible without being dependent on topology configuration specifics.
The generic tests should include all basic driver functions including
authorization, SSL, max values / MongoDB API version, etc.
Comprehensive generic tests are important,
as they both maximize test coverage for the above spectrum of topology configurations
and also minimize the following configuration-dependent test suit.


Topology Tests
''''''''''''''

This directory holds the **Driver Common Topology Test Suite** for MongoDB
that summarizes recommended topology dependent tests.
The feature behavior is described in the `Gherkin language <https://github.com/cucumber/cucumber/wiki/Gherkin>`_
and tests can be automated using `Cucumber <http://cukes.info/>`_,
a tool for `behavior-driven development <http://en.wikipedia.org/wiki/Behavior-driven_development>`_.
Step definitions map feature steps into actual executable test code.
Ruby is used for a reference implementation of the step definitions
which is natural as Ruby is the primary implementation language for Cucumber.

We expect that driver engineers will choose to implement these topology tests as they see fit.
Cucumber can be used for actualizing the test suite,
but manual implementation of the scenarios or step definitions is also acceptable.

To support testing with various topologies,
the `mongo-orchestration <https://github.com/mongodb/mongo-orchestration>`_ project provides
for the setup, teardown, and management of topologies.
Mongo Orchestration can be easily wrapped for more streamlined use.


Pending Feature Descriptions
''''''''''''''''''''''''''''

Incomplete but intended feature descriptions are marked ``@pending``.
Currently pending feature descriptions include configuration related to replica sets or sharded clusters,
as in adding or removing members.

The following features are not currently in the `.feature` files.
Feature descriptions for them will be added to the `.feature` files.


Pinning
```````

Pinning provides more consistent read behavior in a threaded environment.
For a given read preference,
a thread is pinned to a node until the read preference changes.
If the thread were not pinned,
it would get more inconsistent results reading from various members due to differences in replication.

* 1000 reads with nearest should all go to the same node

  * less attractive alternative - two secondaries, 1000 reads all go to the same secondary


Hidden members
``````````````

A test is needed to verify that the driver will not read from a hidden member.

* need preset configuration

  * cannot read from hidden, and it will not become a primary


Postponed Feature Descriptions
''''''''''''''''''''''''''''''

These feature tests are shelved and are not in the `.feature` files.
They may be added when dependent implementation details or infrastructure become available.


Ping Times
``````````

Ping time is implementation dependent and private to the implementation.

References

* `Ping Times - Driver Read Preferences: Specification
  <https://github.com/10gen/specifications/blob/master/source/driver-read-preferences.rst#ping-times>`_
* `Drivers must not use the "ping" command - Server Discovery And Monitoring
  <https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#drivers-must-not-use-the-ping-command>`_
* `This spec does not mandate how round trip time is averaged - Server Discovery And Monitoring
  <https://github.com/mongodb/specifications/blob/master/source/server-discovery-and-monitoring/server-discovery-and-monitoring.rst#this-spec-does-not-mandate-how-round-trip-time-is-averaged>`_


Wire Protocol
`````````````

Wire Protocol Limit depend on configuring a mix of servers and associated wire versions or (max) values.

References

* `Wire Protocol - 10gen / specifications
  <https://github.com/10gen/specifications/blob/master/source/driver-wire-protocol.rst>`_
* `Driver Wire Version Overlap Specification - 10gen / specifications
  <https://github.com/10gen/specifications/blob/master/source/driver-wire-version-overlap-check.rst>`_

Drivers should used the primary for write-related values and operations.
For read related values,
the driver should use the minimimum of the live maxWireVersion values.

* Version
* Limits - Max Values

For adequate testing, this requires a mixed server-version replica-set topology
that is not available in mongo-orchestration.
It is shelved indefinitely.


Write Commands and Write Operations
```````````````````````````````````

Write operations are implemented via write commands for MongoDB version 2.6 or newer
and are implemented with the "old" wire-protocol for MongoDB version 2.4 or older.
For full spectrum testing, unit tests should be run with a matrix
that incorporates server versions
and topology categories including stand-alone server, replica set, and sharded cluster.

Testing beyond this requires a mixed server-version replica-set topology
that is not available via mongo-orchestration.


Feature Descriptions Notes
``````````````````````````

Tags and their meaning or purpose are as follows.

* @destroy - the topology configuration is mutated during the test so destroy it afterwards
* @pending - description of the scenario is not complete or fully working
* @reset - the topology state is modified during the test and must be reset afterwards
* @red_ruby_1.x - the test fails for the Ruby 1.x driver due to a driver issue
* @stable - the topology state is not modified during the test


Test Plan
---------


Feature Descriptions
''''''''''''''''''''

The feature descriptions are tested using the reference implementation in Ruby and the Cucumber software tool.
The following steps outline the method used for development of the feature description.

1. Add a feature description and/or scenario
2. Implement the associated step definitions
3. Test run single scenario with Cucumber and `@solo` tag
4. Iterate until satisfied, then commit

The reference implementation will be added to the continuous integration runs for the Ruby 1.x driver.


Step Definitions
''''''''''''''''

The test suite will be refined and then integrated into other drivers over time.

1. Formally review this specification and improve it
2. Implement the step definitions to realize the test suite in a specific driver and specific programming language
3. Incorporate improvements and iterate with next driver and programming language

Candidates for the next implementation include Perl and Python.

Design Rationale
----------------

The overarching business goal is to improve driver quality and efficiency of development and maintenance
across drivers with respect to supporting the various server topologies.

Topology support is a significant work load for drivers.
Approximately half of the driver code is for topology support, significantly for replica sets.
Replica set behavior is complex and difficult to fully comprehend with all of the details.
This overhead is multiplied by each driver and programming language,
and at present each driver implements their own topology test manager and their own topology test suites.
There is minimal sharing of understanding,
and fluency in another programming language is need to benefit
from knowledge embedded in another driver implementation.
The overall effort to topologies across the spectrum of drivers is a significant problem.
But it is also an opportunity for improving efficiency.

The `mongo-orchestration <https://github.com/mongodb/mongo-orchestration>`_ addresses the need
for a common topology manager that can be used across the drivers.

This **Common Topology Test Suite** is needed as the next major component to complete the necessary groundwork.
The high-level user-story description of behavior features in `Gherkin language <https://github.com/cucumber/cucumber/wiki/Gherkin>`_
is appropriate, and includes the following rationale.

1. It is programming language independent.
2. It can describe distributed system topology and associated behavior.
3. It can be incorporated into documentation.
4. It can be executed using software tools like Cucumber.
5. It builds on test best-practices from `behavior-driven development (BDD) <http://en.wikipedia.org/wiki/Behavior-driven_development>`_.

The results from the reference implementation show the benefit from Gherkin and Cucumber.
Before the reference implementation of the step definitions in Ruby,
we attempted manual coding.
Comparing the experience of manual coding versus Cucumber,
the latter benefits from the steps as pre-factored code as there is no need to
repeatedly copy the step nor its associated code.
More importantly, using Cucumber tests and proves actual feature descriptions
and eliminates inconsistent copies.
For Ruby, using (gem) Cucumber is straightforward and obvious.

For other languages where the environment or integration is more difficult,
driver maintainers are welcome to hand code these tests.
Regardless of implementation choice,
the **Common Tolopology Test Suite** provides readable specification.
It can be refined and augmented as desired.


Reference Implementation
------------------------

The current reference implementation is based on the Ruby driver 1.x-stable branch.


Step definitions
''''''''''''''''

* `step_definitions Ruby 1.x-stable
  <https://github.com/gjmurakami-10gen/mongo-ruby-driver/blob/1.x-mongo-orchestration/features/step_definitions/cluster_steps.rb>`_

  * 53 step definitions
    * 533 lines (Ruby)
  * current execution

    $ rake test:cucumber
    ...
    46 scenarios (46 passed)
    383 steps (383 passed)
    19m37.873s


Mongo Orchestration wrapper
'''''''''''''''''''''''''''

* `mongo_orchestration.rb Ruby 1.x-stable
  <https://github.com/gjmurakami-10gen/mongo-ruby-driver/blob/1.x-mongo-orchestration/test/orchestration/mongo_orchestration.rb>`_
  * 254 lines (implementation)
  * 489 lines (RSpec tests)

Implementation for the 2.x master branch is in progress.


Future Work
-----------


Q & A
-----


---

