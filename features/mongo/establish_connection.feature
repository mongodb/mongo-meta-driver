# language: en
@client
Feature: Establish Connection
  As a user of MongoDB
  In order to interact with MongoDB
  The driver must support connecting to MongoDB
  And if the driver cannot connect to MongoDB
  Then I should get a meaningful error message

  Background:
    Given a MongoDB instance has been launched on host 127.0.0.1 at port 27017

  Scenario: Successfully connecting with a host using a hostname (default port)
    When I request a connection to MongoDB with hostname 127.0.0.1
    Then I will receive a connected client to the instance running on host <host_name> at port 27017

  Scenario: Successfully connecting with a host using a hostname and port
    Given a valid hostname 127.0.0.1
    And a valid port 27017
    When I request a connection to MongoDB with hostname 127.0.0.1 at port 27017
    Then I will receive a connected client to the MongoDB instance on host 127.0.0.1 at port 27017

  # TODO - distinguish between different cases of unacceptable hostnames/ports?
  Scenario: Failing to establish a connection because of invalid hostname
    Given an invalid hostname %@$.com
    And a valid port 27017
    When I request a connection with hostname MongoDB on %@$.com
    Then I will receive an error message stating that hostname %@$.com is invalid
    And I will not receive a client
    
  Scenario: Failing to establish a connection because of invalid port
    Given a valid hostname 127.0.0.1
    And an invalid port -5
    When I request a connection to MongoDB with hostname 127.0.0.1 at port -5
    Then I will receive an error message stating that port -5 is invalid
    And I will not receive a client

  Scenario: Failing to establish a connection because the connection is refused
    Given a valid hostname 127.0.0.1
    And a valid port 27017
    But there is no MongoDB instance running on host 127.0.0.1 at port 27017
    Then I will receive an error message stating that the connection to host 127.0.0.1 at port 27017 was refused
    And I will not receive a client

  #Scenario Outline: Failing to establish a connection because of invalid credentials
  #  Given a valid hostname <host_name> and port <port>
  #  And a MongoDB instance has been launched on <host_name> at port <port>
  #  And I 

  # login scenarios?
