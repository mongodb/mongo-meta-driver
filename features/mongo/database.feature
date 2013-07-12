# language: en
@mongo @interface @database
# TODO: finish the basic things
# TODO: write concern/read preference
# TODO: sharding??
# TODO: authentication?
# stored procedures
# indexes
# profiling

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
    Then I will receive a valid collection corresponding to the collection mycoll on that database

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