# language: en
# TODO: finish the basic things
# TODO: write concern/read preference
# TODO: sharding??
# TODO: authentication?
# stored procedures
# indexes
# profiling
@mongo @interface @database
Feature: Performing CRUD operations on a MongoDB database
  As a user of MongoDB
  In order to read or make changes to a database on a running instance of MongoDB
  Once I have obtained a database object for that database
  I interact with the database via the database object
  Which exposes a CRUD-style interface (create, read, update, delete)

  Background:
    Given I have successfully obtained a database object connected to a database on a running instance of MongoDB
    And the collection mycoll
    And I ask the database for that collection
#  Scenario: Listing collections
#    When I ask the database object for a list of collections
#    Then I will receive a list of the collections in the database

  Scenario: Successfully obtaining a Collection object
    Then I will have a valid collection object corresponding to the collection mycoll on that database

  # insert (Create)
  Scenario: Inserting a single document into an empty collection
    Given the collection has been emptied
    And I am inserting the document {"a" : "b"}
    When I perform this insert operation
    Then the collection should contain only the document {"a" : "b"}

  Scenario: Inserting multiple documents into a nonempty collection
    Given the collection contains only the documents:
      | document               |
      | {"a" : "1", "b" : "2"} |
      | {"a" : "4", "b" : "6"} |
    And I am inserting the documents:
      | document                              |
      | {"a" : "-5", "b" : "16"}              |
      | {"a" : "10", "b" : "0.1", "c" : "-2"} |
    When I perform this insert operation
    Then the collection should contain only the documents:
      | document                              |
      | {"a" : "1", "b" : "2"}                |
      | {"a" : "4", "b" : "6"}                |
      | {"a" : "-5", "b" : "16"}              |
      | {"a" : "10", "b" : "0.1", "c" : "-2"} |

  # delete (Demove)
  Scenario: Deleting from a collection
    Given the collection contains only the documents:
      | document               |
      | {"a" : "b", "1" : "6"} |
      | {"a" : "b", "1" : "7"} |
    And I am deleting documents matching the document {"1" : "6"}
    When I perform this delete operation
    Then the collection should contain only the document {"a" : "b", "1" : "7"}

  Scenario: Attempting to delete from a collection with no matching documents
    Given the collection contains only the documents:
      | document                                                       |
      | {"a" : "b", "1" : "6"}                                         |
      | {"a" : "b", "1" : "7"}                                         |
      | {"age" : "6", "address" : {"street" : "43", "number" : "277"}} |
    And I am deleting documents matching the document {"age" : {"$lt" : "5"}}
    When I perform this delete operation
    Then the collection should contain only the documents:
      | document                                                       |
      | {"a" : "b", "1" : "6"}                                         |
      | {"a" : "b", "1" : "7"}                                         |
      | {"age" : "6", "address" : {"street" : "43", "number" : "277"}} |


  # query (Read)
  Scenario: Querying on a collection
    Given the collection contains only the documents:
      | document               |
      | {"a" : "b", "c" : "6"} |
      | {"a" : "b", "c" : "5"} |
      | {"c" : "b", "c" : "4"} |
      | {"a" : "b", "c" : "3"} |
      | {"a" : "c", "c" : "1"} |
    And I am querying for documents matching the document {"a" : "b", "c" : {"$lte" : "5"}}
    When I perform this query
    Then I should receive the documents:
      | document               |
      | {"a" : "b", "c" : "5"} |
      | {"a" : "b", "c" : "3"} |

  # update (Update)
  Scenario: Updating a collection successfully
    Given the collection contains only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |
    And I am updating the document matching the document {"name" : "mario"}
    And I am performing the update specified by the document {"$set" : {"profession" : "hacker"}}
    When I perform this update
    Then the collection should contain only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "hacker"}       |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |

  Scenario: Attempting to update a collection with no matching documents
    Given the collection contains only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |
    And I am updating the document matching the document {"name" : "spiderman"}
    And I am performing the update specified by the document {"$set" : {"profession" : "photographer"}}
    When I perform this update
    Then the collection should contain only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |

  Scenario: Upsert that inserts a new document
    Given the collection contains only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |
    And I am updating the document matching the document {"name" : "spiderman"}
    And I am performing the update specified by the document {"$set" : {"profession" : "photographer"}}
    And I am doing an upsert
    When I perform this update
    Then the collection should contain only the documents:
      | document                                              |
      | {"name" : "mario", "profession" : "plumber"}          |
      | {"name" : "batman", "profession" : "superhero"}       |
      | {"name" : "superman", "profession" : "superhero"}     |
      | {"name" : "spiderman", "profession" : "photographer"} |

  Scenario: Multi update with multiple matching documents
    Given the collection contains only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "superhero"}   |
      | {"name" : "superman", "profession" : "superhero"} |
    And I am updating documents matching the document {"profession" : "superhero"}
    And I am performing the update specified by the document {"$set" : {"profession" : "vigilante"}}
    And I am doing a multi update
    When I perform this update
    Then the collection should contain only the documents:
      | document                                          |
      | {"name" : "mario", "profession" : "plumber"}      |
      | {"name" : "batman", "profession" : "vigilante"}   |
      | {"name" : "superman", "profession" : "vigilante"} |

  Scenario:
    Given


  # get more
  # kill cursors
  # parse db replies??

# renaming, dropping, ... a collection

#  Scenario: Renaming a collection
#    When I ask the database object to change the name of collection <coll_name1> to <coll_name2>
#    And <coll_name1> is a valid collection name
#    And <coll_name2> is a valid collection name
#    And collection <coll_name1> exists
#    And collection <coll_name2> does not exist
#    When I ask the database object for collection <coll_name1>
#    Then I will receive the error that <coll_name1> does not exist
#    When I ask the database for collection <coll_name2>
#    # TODO - ensure that
     # TODO - options!!!!!
#    Then I will receive a collection object for <coll_name2>

# TODO: getting collections from an invalid db