
Feature: Tests for the home page

    Background: Define url
        Given url apiUrl
        #       * print apiUrl 
 
    Scenario: Get all tags
        #       Given url 'https://conduit-api.bondaracademy.com/api/tags'
        Given path 'tags'
        When method Get
        Then status 200
        #        And match response.tags contains 'Test'
        And match response.tags contains ['Test', 'YouTube']
        And match response.tags !contains 'Testing'
        And match response.tags contains any ['Academy', 'Git']
        #       And match response.tags contains only ['All items']
        And match response.tags == "#array"
        And match each response.tags == "#string"

    
    # @ignore @skipme
    Scenario: Get 10 articles from page
        * def timeValidator = read('classpath:helpers/timeValidator.js')
        #        Given param limit = 10
        #        Given param offset = 0
        Given params { limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        And match response.articles == '#[10]'
        #       And match response.articlesCount == 10
        #       And match response.articlesCount != 10
        # The match can do it even an Objects, articles contains two variables one type array and integer
        #       And match response = {articles: "#array", articlesCount: 400}
        And match response.articles[0].createdAt contains '2024'
        # all values [*] or ..
        And match response.articles[*].favoritesCount contains 0
        And match response..bio contains null
        And match each response..following == false
        And match each response..following == '#boolean'
        # can be null or string
        And match each response..bio == '##string'
        # schema validation, for each object of the list
        And match each response.articles ==
        """
            {
                "slug": "#string",
                "title": "#string",
                "description": "#string",
                "body": "#string",
                "tagList": '#array',
                "createdAt": "#? timeValidator(_)",
                "updatedAt": "#? timeValidator(_)",
                "favorited": "#boolean",
                "favoritesCount": "#number",
                "author": {
                    "username": "#string",
                    "bio": '##string',
                    "image": "#string",
                    "following": '#boolean'
                }
            }
        """

    Scenario: Conditional logic
        Given params { limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        * def favoritesCount = response.articles[0].favoritesCount
        * def article = response.articles[0]

#        * if (favoritesCount == 0) karate.call('classpath:helpers/AddLikes.feature', article)
        * def result = favoritesCount == 0 ? karate.call('classpath:helpers/AddLikes.feature', article).likesCount : favoritesCount

        Given params { limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        And match response.articles[0].favoritesCount == result

    Scenario: Retry call
        * configure retry = { count: 10, interval: 5000 }
        
        Given params { limit: 10, offset: 0}
        Given path 'articles'
        And retry until response.articles[0].favoritesCount == 1
        When method Get
        Then status 200

    Scenario: Sleep call
        * def sleep = function(pause){ java.lang.Thread.sleep(pause) }
        
        Given params { limit: 10, offset: 0}
        Given path 'articles'
        When method Get
        * eval sleep(10000)
        Then status 200

    Scenario: Number to string
        * def foo = 10
        * def json = {"bar": #(foo+'')}
        * match json == {"bar": '10' }

    Scenario: String to number
        * def foo = '10'
        * def json = {"bar": #(foo*1)}
        * def json2 = {"bar": #(~~parseInt(foo))}
        * match json == {"bar": 10 }
        * match json2 == {"bar": 10 }