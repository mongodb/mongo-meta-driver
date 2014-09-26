=========================================
MongoDB Driver Common Topology Test Suite
=========================================

This directory holds the **Driver Common Topology Test Suite** for MongoDB.
This is a suite of feature descriptions for MongoDB drivers according to specifications and documentation.
This suite is for behavior that depends on actual topology configurations and details,
features that are not dependent on server topology should be covered elsewhere.

The test suite is intended to help driver authors and maintainers
understand, implement and verify driver behavior.

The suite does *not* attempt exhaustive code coverage or compliance,
but should provide a reasonable balance between run time and feature testing.
We welcome improvements to the test suite.
This is *work in progress*.

The following subdirectories contain feature descriptions in
the `Gherkin language <https://github.com/cucumber/cucumber/wiki/Gherkin>`_.

* `standalone <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/standalone>`_
* `replica_set <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/replica_set>`_
* `sharded_cluster <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/sharded_cluster>`_

For further description and details,
please see the **MongoDB Driver Common Topology Test Suite** specification document.

* `common-topology-test-suite.rst (reStructured Text) <https://github.com/mongodb/mongo-meta-driver/tree/master/features/topology/common-topology-test-suite.rst>`_
