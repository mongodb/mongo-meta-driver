# language: en
# TODO: finish the basic things
# TODO: write concern/read preference
# TODO: sharding??
# TODO: authentication?
# stored procedures
# indexes
# profiling
@mongo @interface @database
Feature: Interacting with the Database object
  As a user of MongoDB
  In order to read or make changes to a database on a running instance of MongoDB
  Once I have obtained a database object for that database
  I interact with the database via the database object

  Background:
    Given I have successfully obtained a database object connected to a database on a running instance of MongoDB

#  Scenario: Listing collections
#    When I ask the database object for a list of collections
#    Then I will receive a list of the collections in the database

  Scenario: Successfully obtaining a Collection object
    Given the collection mycoll
    When I ask the database for that collection
    Then I will receive a valid collection object corresponding to the collection mycoll on that database

  # should be empty first
  Scenario: Inserting into a collection
    Given the collection mycoll
    And the collection has been emptied
    When I ask the database for that collection
    And I ask the collection to insert the document {"a" : "b"}
    Then the collection should contain only the document {"a" : "b"}

  # contains only?
  Scenario: Deleting from a collection
    Given the collection mycoll
    And the collection contains the document {"a" : "b", "1" : "6"}
    When I ask the collection to delete all documents matching the document {"a" : "b"}
    Then the collection should not contain the document {"a" : "b", "1" : "6"}

  # need to be able to deal with replies from the db
  Scenario: Querying on a collection
    Given the collection mycoll
    And the collection contains the documents:
      | document               |
      | {"a" : "b", "1" : "6"} |
      | {"a" : "b", "1" : "5"} |
      | {"c" : "b", "1" : "4"} |
      | {"a" : "b", "1" : "3"} |
    When I query the collection using the document {"a" : "b", "1" : {"$lt" : "5"}}
    Then I should receive the documents:
      | document               |
      | {"a" : "b", "1" : "5"} |
      | {"a" : "b", "1" : "3"} |

  # get more
  # kill cursors
  # parse db replies??
  Scenario:

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
#    Then I will receive a collection object for <coll_name2>

# TODO: getting collections from an invalid db