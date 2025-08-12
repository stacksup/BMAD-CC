#!/bin/bash
# BMAD-CC Docker Development Helper Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project configuration
PROJECT_NAME="bmad-cc"
CONTAINER_NAME="bmad-cc-dev"

# Helper functions
print_header() {
    echo -e "${BLUE}🐳 BMAD-CC Docker Development Environment${NC}"
    echo -e "${BLUE}=========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Command functions
cmd_build() {
    print_header
    echo "Building BMAD-CC development container..."
    docker-compose build --no-cache
    print_success "Container built successfully"
}

cmd_start() {
    print_header
    echo "Starting BMAD-CC development environment..."
    docker-compose up -d
    
    # Wait for services to be healthy
    echo "Waiting for services to start..."
    sleep 5
    
    # Check health status
    if docker-compose ps | grep -q "healthy\|Up"; then
        print_success "BMAD-CC development environment is running"
        echo ""
        echo "Available services:"
        echo "  🚀 BMAD-CC Dev Container: http://localhost:3000"
        echo "  🗄️  PostgreSQL: localhost:5433"
        echo "  🔴 Redis: localhost:6380"
        echo ""
        echo "To enter the container: ./docker-dev.sh shell"
        echo "To view logs: ./docker-dev.sh logs"
    else
        print_error "Some services failed to start properly"
        cmd_logs
    fi
}

cmd_stop() {
    print_header
    echo "Stopping BMAD-CC development environment..."
    docker-compose down
    print_success "Environment stopped"
}

cmd_restart() {
    cmd_stop
    sleep 2
    cmd_start
}

cmd_shell() {
    print_header
    echo "Entering BMAD-CC development container..."
    echo -e "${YELLOW}Note: Task Master is pre-installed and ready to use${NC}"
    docker-compose exec bmad-cc /bin/bash
}

cmd_logs() {
    print_header
    echo "Showing BMAD-CC container logs..."
    docker-compose logs -f bmad-cc
}

cmd_status() {
    print_header
    echo "BMAD-CC Development Environment Status:"
    echo ""
    
    if docker-compose ps | grep -q "${CONTAINER_NAME}.*Up"; then
        print_success "BMAD-CC container is running"
        
        # Check Task Master availability
        if docker-compose exec -T bmad-cc task-master --version >/dev/null 2>&1; then
            print_success "Task Master is available"
        else
            print_warning "Task Master may not be properly installed"
        fi
    else
        print_warning "BMAD-CC container is not running"
    fi
    
    echo ""
    echo "Container status:"
    docker-compose ps
}

cmd_taskmaster_init() {
    print_header
    echo "Initializing Task Master in BMAD-CC container..."
    
    docker-compose exec bmad-cc bash -c "
        if [ ! -d '.taskmaster' ]; then
            echo 'Initializing Task Master...'
            task-master init -y
            task-master models --set-main opus
            task-master models --set-fallback sonnet
            echo 'Task Master initialized successfully'
        else
            echo 'Task Master already initialized'
        fi
    "
    
    print_success "Task Master setup complete"
}

cmd_clean() {
    print_header
    echo "Cleaning up BMAD-CC development environment..."
    docker-compose down -v --remove-orphans
    docker system prune -f
    print_success "Environment cleaned"
}

cmd_help() {
    print_header
    echo "Available commands:"
    echo ""
    echo "  build     - Build the BMAD-CC development container"
    echo "  start     - Start the development environment"
    echo "  stop      - Stop the development environment"
    echo "  restart   - Restart the development environment"
    echo "  shell     - Enter the BMAD-CC development container"
    echo "  logs      - Show container logs"
    echo "  status    - Show environment status"
    echo "  taskmaster - Initialize Task Master in container"
    echo "  clean     - Clean up environment and volumes"
    echo "  help      - Show this help message"
    echo ""
    echo "Example usage:"
    echo "  ./docker-dev.sh build"
    echo "  ./docker-dev.sh start"
    echo "  ./docker-dev.sh shell"
}

# Main command dispatcher
case "${1:-help}" in
    build)
        cmd_build
        ;;
    start)
        cmd_start
        ;;
    stop)
        cmd_stop
        ;;
    restart)
        cmd_restart
        ;;
    shell)
        cmd_shell
        ;;
    logs)
        cmd_logs
        ;;
    status)
        cmd_status
        ;;
    taskmaster)
        cmd_taskmaster_init
        ;;
    clean)
        cmd_clean
        ;;
    help|--help|-h)
        cmd_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        cmd_help
        exit 1
        ;;
esac