FROM maven:3.8-openjdk-17 AS builder
WORKDIR /app
COPY . .
RUN mvn -B clean package -DskipTests

# Runtime stage
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8084
ENTRYPOINT ["java", "-jar", "app.jar"]