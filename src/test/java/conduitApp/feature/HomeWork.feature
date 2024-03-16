
Feature: Home Work

    Background: Preconditions
        * url apiUrl 
        # this must read here even if the schema is in json file
        * def timeValidator = read('classpath:helpers/timeValidator.js')
        * def dataGenerator = Java.type('helpers.DataGenerator')
        * def commentResponseSchema = read('classpath:conduitApp/json/response/commentSchema.json');
        * def articleResponseSchema = read('classpath:conduitApp/json/response/articleSchema.json');
        * def favoriteArticleResponseSchema = read('classpath:conduitApp/json/response/favoriteArticleSchema.json');
    

    Scenario: Favorite articles
        # Step 1: Get atricles of the global feed
        Given params { limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        # Step 2: Get the favorites count and slug ID for the first article, save it to variables
        * def firstSlugId = response.articles[0].slug
        * def initialFavoritesCount = response.articles[0].favoritesCount
        * print initialFavoritesCount

        # Step 3: Make POST request to increse favorites count for the first article
        Given headers { Content-Length: 0 }
        Given path 'articles', firstSlugId, 'favorite' 
        When method Post
        Then status 200
        # Step 4: Verify response schema
        And match response == favoriteArticleResponseSchema
        # Step 5: Verify that favorites article incremented by 1
        * def initialCount = 0
        * match initialFavoritesCount == initialCount + 1

        # Step 6: Get all favorite articles
        Given params { favorited: #(username), limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        # Step 7: Verify response schema
        And match each response.articles == articleResponseSchema
        # Step 8: Verify that slug ID from Step 2 exist in one of the favorite articles
        And match response.articles[*].slug contains firstSlugId

    Scenario: Comment articles
        # Step 1: Get atricles of the global feed
        Given params { limit: 10, offset: 0 }
        Given path 'articles'
        When method Get
        Then status 200
        # Step 2: Get the slug ID for the first arice, save it to variable
        * def firstSlugId = response.articles[0].slug

        # Step 3: Make a GET call to 'comments' end-point to get all comments
        Given path 'articles', firstSlugId, 'comments' 
        When method Get
        Then status 200

        # Step 4: Verify response schema
        * def commentSchema = response.comments.length == 0 ?  {"comments":"#[]"} : commentResponseSchema

        # i need to validate if array is empty do match or match each
        And match response.comments contains commentSchema.comments
        # Step 5: Get the count of the comments array lentgh and save to variable
            #Example
        * def initialComments =  response.comments.length
        * print initialComments
        # Step 6: Make a POST request to publish a new comment
        # Given headers { Content-Length: 0 }
        Given path 'articles', firstSlugId, 'comments' 
        And request { comment: { body: #(dataGenerator.getRandomComment().comment) }}
        When method Post
        Then status 200

        # Step 7: Verify response schema that should contain posted comment text
        And match response.comment == commentResponseSchema.comments
        * def idComment = response.comment.id
        # Step 8: Get the list of all comments for this article one more time
        Given path 'articles', firstSlugId, 'comments' 
        When method Get
        Then status 200
        # Step 9: Verify number of comments increased by 1 (similar like we did with favorite counts)
        * def increasedComments = response.comments.length
        And match increasedComments == initialComments + 1 
        * print increasedComments

        # Step 10: Make a DELETE request to delete comment
        Given path 'articles', firstSlugId, 'comments', idComment 
        When method Delete
        Then status 200

        # Step 11: Get all comments again and verify number of comments decreased by 1
        Given path 'articles', firstSlugId, 'comments' 
        When method Get
        Then status 200

        * def finalComments = response.comments.length
        And match finalComments == initialComments


        