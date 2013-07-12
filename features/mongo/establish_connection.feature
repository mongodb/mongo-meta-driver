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
    Given the hostname 127.0.0.1
    When I request a connection to MongoDB with that hostname
    Then I will receive a connected client to the MongoDB instance running on host 127.0.0.1 at port 27017

  Scenario: Successfully connecting with a host using a hostname and port
    Given the hostname 127.0.0.1
    And the port 27017
    When I request a connection to MongoDB with that hostname and port
    Then I will receive a connected client to the MongoDB instance running on host 127.0.0.1 at port 27017

  # TODO - distinguish between different cases of unacceptable hostnames/ports, or failed connections generally?
  Scenario: Failing to establish a connection because host does not exist
    Given the hostname example.com
    And the port 27017
    When I request a connection to MongoDB with that hostname and port
    Then I will receive an error message stating that the connection failed
    And I will not receive a client

  Scenario: Failing to establish a connection because of invalid port
    Given the hostname 127.0.0.1
    And the port -5
    When I request a connection to MongoDB with that hostname and port
    Then I will receive an error message stating that the connection failed
    And I will not receive a client
#
#  Scenario: Failing to establish a connection because the connection is refused
#    Given the hostname 127.0.0.1
#    And the port 27017
#    But there is no MongoDB instance running on host 127.0.0.1 at port 27017
#    When I request a connection to MongoDB with that hostname and port
#    Then I will receive an error message stating that the connection to host 127.0.0.1 at port 27017 was refused
#    And I will not receive a client

  #Scenario Outline: Failing to establish a connection because of invalid credentials
  #  Given a valid hostname <host_name> and port <port>
  #  And a MongoDB instance has been launched on <host_name> at port <port>
  #  And I 

  # login scenarios?
