function fn() {
  var env = karate.env; // get system property 'karate.env'
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    apiUrl: 'https://conduit-api.bondaracademy.com/api/'
  }
  if (env == 'dev') {
    config.userEmail = 'maxi@maxi.maxi'
    config.username = 'maxi'
    config.userPassword = 'maximaxi'
    
  } else if (env == 'qa') {
    config.userEmail = 'QA@maxi.maxi'
    config.userPassword = 'maximaxi'
  }

  // obtain token from the feature
  var accessToken = karate.callSingle('classpath:helpers/CreateToken.feature', config).authToken
  // Configure a global header
  karate.configure('headers', { Authorization: 'Token ' + accessToken })

  return config;
}