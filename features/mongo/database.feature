# language: en
@mongo
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

  Scenario: Listing collections
    When I ask the database object for a list of collections
    Then I will receive a list of collection in the database

  Scenario Outline: Successfully obtaining a Collection object
    When I ask the database object for collection <coll_name>
    And <coll_name> is a valid collection name
    And collection <coll_name> exists
    Then I will receive a collection object for collection <coll_name>

    Examples:

  Scenario: Creating a collection
    When I ask the database object to create a collection <coll_name>
    And <coll_name> is a valid collection name
    And collection <coll_name> does not exist
    When I ask the database for collection <coll_name>
    Then I will receive a collection object for collection <coll_name>

  # creating a collection that already exists
  Scenario: Trying to create a collection that already exists
    When I ask the database object to create a collection <coll_name>
    And <coll_name> is a valid collection name
    But collection <coll_name> exists
    Then I will receive the error that collection <coll_name> already exists

  Scenario: Renaming a collection
    When I ask the database object to change the name of collection <coll_name1> to <coll_name2>
    And <coll_name1> is a valid collection name
    And <coll_name2> is a valid collection name
    And collection <coll_name1> exists
    And collection <coll_name2> does not exist
    When I ask the database object for collection <coll_name1>
    Then I will receive the error that <coll_name1> does not exist
    When I ask the database for collection <coll_name2>
    # TODO - ensure that
    Then I will receive a collection object for <coll_name2>

  Scenario: Dropping a collection

  Scenario: Adding a user

  Scenario: Dropping a user
    
  
