# Service Registry

Netflix Eureka service discovery server for the ScholarAI microservices ecosystem.

## Features

- **Service Discovery**: Automatic registration and discovery of microservices
- **Health Monitoring**: Continuous health checks with automatic deregistration
- **Load Balancing**: Client-side load balancing across service instances
- **Dashboard**: Web-based UI for service registry visualization

## Prerequisites

- Java 21+
- Maven 3.8+ (or use included wrapper)
- Docker (optional)

## Quick Start

### Local Development

```bash
# Build the project
./mvnw clean install

# Run the service
./mvnw spring-boot:run
```

Access the Eureka dashboard at `http://localhost:8761`

### Using Scripts

```bash
# Local development
./scripts/local.sh build
./scripts/local.sh run

# Docker deployment
./scripts/docker.sh build
./scripts/docker.sh run
```

### Docker Compose

```bash
docker-compose up -d
docker-compose logs -f
docker-compose down
```

## Configuration

Default configuration runs on port 8761 with standalone mode (no self-registration).

Key settings in `application.properties`:
- `server.port=8761` - Eureka server port
- `eureka.server.enable-self-preservation=false` - Disabled for faster failure detection
- `eureka.server.eviction-interval-timer-in-ms=10000` - Eviction check interval

## API Endpoints

### Health & Management
- `GET /actuator/health` - Service health status
- `GET /actuator/info` - Application information
- `GET /actuator/metrics` - Application metrics

### Service Registry
- `GET /eureka/apps` - All registered applications
- `GET /eureka/apps/{appName}` - Specific application instances

## Testing

```bash
# Run tests
./mvnw test

# Build with tests
./mvnw clean package
```

## Production Deployment

For production, enable self-preservation and adjust thresholds:

```properties
eureka.server.enable-self-preservation=true
eureka.server.renewal-percent-threshold=0.85
```

## Troubleshooting

### Service Not Registering
Check network connectivity and verify client configuration points to the correct registry URL.

### Self-Preservation Mode
In development, self-preservation is disabled. For production, this should be enabled to prevent false evictions during network issues.

## License

MIT License
