FROM maven:3.6-jdk-11-slim as BUILD
WORKDIR /petclinic

COPY pom.xml ./
COPY src ./src

RUN mvn spring-javaformat:apply

RUN mvn clean package

FROM openjdk:11-jre-slim

COPY --from=build /petclinic/target/spring-petclinic-*.jar /petclinic.jar

EXPOSE 3000

CMD ["java", "-jar", "-Dserver.port=3000", "petclinic.jar"]

# RUN echo «Hello from me!!»