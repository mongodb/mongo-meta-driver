MongoDB Driver Common Topology Test Suite
=========================================

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

The specification document can be found online.

* `common-topology-test-suite.rst <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/common-topology-test-suite.rst>`_

This document file follows
the `MongoDB Documentation Style Guidelines <http://docs.mongodb.org/manual/meta/style-guide/>`_.
It is in `reStructuredText <http://docutils.sourceforge.net/rst.html>`_ form,
intended for `GitHub Markup <https://github.com/github/markup>`_.

