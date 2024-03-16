
Feature: Articles

    Background: Define url
        * url apiUrl
        # Given path 'users/login'
        # And request {user: { email: "maxi@maxi.maxi", password: "maximaxi"}}
        # When method Post
        # Then status 200

        # we are getting this data by global variables in karate-config.js
        # 'callonce' tries to get the token variable of the function, once per function
        #       * def tokenResponse = callonce read('classpath:helpers/CreateToken.feature')
        #       * def token = tokenResponse.authToken
        * def articleRequestBody = read('classpath:conduitApp/json/request/newArticleRequest.json')
        * def dataGenerator = Java.type('helpers.DataGenerator')
        * set articleRequestBody.article.title = dataGenerator.getRandomArticleValues().title
        * set articleRequestBody.article.description = dataGenerator.getRandomArticleValues().description
        * set articleRequestBody.article.body = dataGenerator.getRandomArticleValues().body

      
    Scenario: Create a new article
        Given path 'articles'
        And request articleRequestBody
        When method Post
        Then status 201
        And match response.article.title == articleRequestBody.article.title

    Scenario: Create and Delete article
        Given path 'articles'
        And request articleRequestBody
        When method Post
        Then status 201
        * def articleId = response.article.slug

        Given params { offset: 0, limit: 10 }
        Given path 'articles'
        When method Get
        Then status 200
        And match response.articles[0].title == articleRequestBody.article.title

        Given path 'articles',articleId
        When method Delete
        Then status 204

        Given params { offset: 0, limit: 10 }
        Given path 'articles'
        When method Get
        Then status 200
        And match response.articles[0].title != articleRequestBody.article.title
