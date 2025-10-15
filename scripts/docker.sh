#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

APP_NAME="service_registry"
CONTAINER_NAME="scholar-service-registry"
IMAGE_NAME="scholar-service-registry:latest"
NETWORK_NAME="scholarai-network"
DEFAULT_PORT=8761

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
    
    print_success "Docker and Docker Compose are available"
}

create_network() {
    if ! docker network ls | grep -q "$NETWORK_NAME"; then
        print_status "Creating Docker network: $NETWORK_NAME"
        docker network create "$NETWORK_NAME"
        print_success "Network $NETWORK_NAME created"
    else
        print_status "Network $NETWORK_NAME already exists"
    fi
}

build() {
    print_status "Building Docker image for $APP_NAME..."
    create_network
    docker-compose build
    print_success "Docker image built successfully!"
}

rebuild_nocache() {
    print_status "Rebuilding Docker image for $APP_NAME without cache..."
    create_network
    docker-compose down --rmi all
    docker-compose build --no-cache --pull
    print_success "Docker image rebuilt successfully without cache!"
}

run() {
    print_status "Starting $APP_NAME container..."
    
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_warning "Container $CONTAINER_NAME is already running"
        print_status "Use 'docker.sh stop' to stop it first"
        return 1
    fi
    
    create_network
    docker-compose up -d
    print_success "Container started successfully!"
    print_status "Service Registry is available at http://localhost:$DEFAULT_PORT"
    
    sleep 10
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        print_error "Container failed to start. Check logs:"
        docker-compose logs
        exit 1
    fi
    
    print_success "Service Registry is running successfully!"
}

stop() {
    print_status "Stopping $APP_NAME container..."
    docker-compose down
    print_success "Container stopped successfully!"
}

restart() {
    print_status "Restarting $APP_NAME container..."
    stop
    sleep 2
    run
}

status() {
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_success "Container $CONTAINER_NAME is running"
        print_status "Service Registry: http://localhost:$DEFAULT_PORT"
        docker ps --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        print_warning "Container $CONTAINER_NAME is not running"
    fi
}

logs() {
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        docker-compose logs -f
    else
        print_warning "Container $CONTAINER_NAME does not exist"
    fi
}

clean() {
    print_status "Cleaning up..."
    stop
    
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        docker rm "$CONTAINER_NAME"
    fi
    
    if docker images | grep -q "scholar-service-registry"; then
        docker rmi "$IMAGE_NAME"
    fi
    
    print_success "Cleanup completed!"
}

show_help() {
    echo "Service Registry Docker Management Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  build                    Build the Docker image"
    echo "  rebuild-nocache          Rebuild the Docker image without cache"
    echo "  run                      Start the container"
    echo "  stop                     Stop the container"
    echo "  restart                  Restart the container"
    echo "  status                   Show container status"
    echo "  logs                     Show container logs (follow mode)"
    echo "  clean                    Stop container, remove container and image"
    echo "  help                     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 build"
    echo "  $0 run"
    echo "  $0 logs"
}

main() {
    cd "$(dirname "$0")/.."
    check_docker
    
    case "${1:-help}" in
        "build")
            build
            ;;
        "rebuild-nocache")
            rebuild_nocache
            ;;
        "run")
            run
            ;;
        "stop")
            stop
            ;;
        "restart")
            restart
            ;;
        "status")
            status
            ;;
        "logs")
            logs
            ;;
        "clean")
            clean
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
