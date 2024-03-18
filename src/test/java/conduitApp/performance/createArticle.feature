@performance
Feature: Articles

  Background: Define url
    * url apiUrl
    * def articleRequestBody = read('classpath:conduitApp/json/request/newArticleRequest.json')
    * def dataGenerator = Java.type('helpers.DataGenerator')
    * set articleRequestBody.article.title = dataGenerator.getRandomArticleValues().title
    * set articleRequestBody.article.description =  __gatling.Description
    * set articleRequestBody.article.body = dataGenerator.getRandomArticleValues().body
    * def authToken = 'Token ' + __gatling.token

  @debug
  Scenario: Create and delete article
    # With this configure we obtain from createTokens the tokens of data 
    * configure headers = {"Authorization": #(authToken)}
    # * configure headers = {"Authorization": 'Token ' + #(authToken)}
    Given path 'articles'
    And request articleRequestBody
    And header karate-name = 'Title requested: ' + articleRequestBody.article.title
    When method Post
    Then status 201
    * def articleId = response.article.slug

    * karate.pause(5000)

    Given path 'articles',articleId
    When method Delete
    Then status 204