
Feature: Sign Up new user

    Background: Preconditions
        * def dataGenerator = Java.type('helpers.DataGenerator')
        * def timeValidator = read('classpath:helpers/timeValidator.js')
        * def randomEmail = dataGenerator.getRandomEmail()
        * def randomUsername = dataGenerator.getRandomUsername()
        Given url apiUrl


    Scenario: New user Sign Up
        #       Given def userData = { email: "aa@aaasdaas.a", username: "loasdcssa"}
        Given path 'users'
        And request 
        """
            {
                user: {
                    email:#(randomEmail),
                    password: "12345678",
                    username: #(randomUsername)
                }
            } 
        """
        When method Post
        Then status 201
        And match response ==
        """
           {
                "user": {
                    "id": "#number",
                    "email": #(randomEmail),
                    "username": #(randomUsername),
                    "bio": null,
                    "image": "#string",
                    "token": "#string"
                 }
            }
        """

    # Data Driven Test
    Scenario Outline: Validate Sign Up error messages   
        Given path 'users'
        And request 
        """
            {
                user: {
                    email:"<email>",
                    password: "<password>",
                    username: "<username>"
                }
            } 
        """
        When method Post
        Then status 422
        And match response == <errorResponse>

        Examples:
            | email          | password  | username                  | errorResponse                                                                      |
            | #(randomEmail) | karate123 | random                    | {"errors": { "username": ["has already been taken"]}}                              |
            | maxi@maxi.maxi | karate123 | #(randomUsername)         | {"errors": { "email": ["has already been taken"]}}                                 |
            |                | Karate123 | #(randomUsername)         | {"errors":{"email":["can't be blank"]}}                                            | 
            | #(randomEmail) |           | #(randomUsername)         | {"errors":{"password":["can't be blank"]}}                                         |
            | #(randomEmail) | Karate123 |                           | {"errors":{"username":["can't be blank"]}} | 
    #        | KarateUser     | Karate123 | #(randomUsername)         | {"errors":{"email":["is invalid"]}}                                                |
    #        | #(randomEmail) | Karate123 | KarateUser12312312sdf3123 | {"errors":{"username":["is too long (maximum is 20 characters)"]}}                 | 
    #        | #(randomEmail) | Kar       | #(randomUsername)         | {"errors":{"password":["is too short (minimum is 8 characters)"]}}                 | 
