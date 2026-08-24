# =============================================================================
# Multi-stage Dockerfile for all ecommerce microservices
# Usage: docker build --build-arg SERVICE_NAME=auth-service -t auth-service .
# The docker-compose.yml passes SERVICE_NAME per service automatically.
# =============================================================================

# ─── Stage 1: Build ──────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17-alpine AS builder

ARG SERVICE_NAME
ENV SERVICE_NAME=${SERVICE_NAME}

WORKDIR /workspace

# Copy root POM first (dependency resolution layer)
COPY pom.xml .

# Copy common-lib (ALL services depend on it – must be installed before building any service)
COPY common-lib/pom.xml common-lib/pom.xml
COPY common-lib/src    common-lib/src

# Copy the target service source
COPY ${SERVICE_NAME}/pom.xml ${SERVICE_NAME}/pom.xml
COPY ${SERVICE_NAME}/src     ${SERVICE_NAME}/src

# Build: install common-lib into local Maven repo, then package the service
# -am: also build upstream modules, -pl: select modules to build
RUN mvn -pl common-lib,${SERVICE_NAME} -am \
        -o --fail-fast \
        clean package -DskipTests \
        2>/dev/null || \
    mvn -pl common-lib,${SERVICE_NAME} -am \
        clean package -DskipTests

# ─── Stage 2: Runtime ────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine AS runtime

ARG SERVICE_NAME
ENV SERVICE_NAME=${SERVICE_NAME}

# Create non-root user for security
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy the fat JAR from the build stage
COPY --from=builder /workspace/${SERVICE_NAME}/target/*.jar app.jar

# Set ownership
RUN chown appuser:appgroup app.jar

USER appuser

# Expose a generic port — overridden per service via SERVER_PORT env var
EXPOSE 8080

# JVM tuning for containers: respect cgroup memory limits
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
