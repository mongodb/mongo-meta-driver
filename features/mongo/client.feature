# language: en
# TODO: rename/drop databases?
@mongo
Feature: Interacting with a connected Mongo client object
  As a user of MongoDB
  In order to gain access to individual databases on a running instance of MongoDB
  Or change global settings on that instance
  Or change the properties of my connection to that instance
  Once I have obtained a client object connected to that instance
  I interact with the instance via the client object

  Background:
    Given I have successfully obtained a client object connected to a running instance of MongoDB
    
  Scenario: Listing Databases
    When I ask the client object for a list of databases
    Then I will receive a list of databases on the server

  Scenario Outline: Successfully obtaining a Database object
    When I ask the client object for database <db_name>
    And <db_name> is a valid database name
    Then I will receive a database object for database <db_name>

    Examples:
    
  # TODO: replica set/master/slave functionality
  # TODO: support configuring a connected client
