# Build Stage: Use Maven to build the backend
FROM maven:3.9.4-eclipse-temurin-17 AS build
# Set working directory
WORKDIR /app
# Copy Maven configuration and source files
COPY pom.xml .
RUN mvn dependency:go-offline
COPY src ./src

# Build the Spring Boot application
RUN mvn clean package -DskipTests
#RUN mvn clean package

# Runtime Stage: Use a lightweight JDK to run the app
FROM eclipse-temurin:17-jdk-jammy

# Set working directory
WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application's port
EXPOSE 8080


# Run the Spring Boot application
ENTRYPOINT ["java", "-jar", "app.jar"]
