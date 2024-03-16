FROM maven:3.9.0-eclipse-temurin-19-focal

WORKDIR /usr/src/app

COPY pom.xml /usr/src/app
COPY ./src/test/java /usr/src/app/src/test/java

CMD mvn test