#!/usr/bin/env bash
# Docker Container Management for BMAD Projects
# Assumes all projects run in Docker containers

set -e

# Default parameters
ACTION="${1:-status}"
SERVICE="${2:-all}"
FORCE="${3:-false}"

# Configuration
PROJECT_NAME="BMAD-CC"
PROJECT_TYPE="framework"  # Fixed from "Framework"
DOCKER_COMPOSE_FILE="${DOCKER_COMPOSE_FILE:-docker-compose.yml}"
FRONTEND_PORT="${FRONTEND_PORT:-3000}"
BACKEND_PORT="${BACKEND_PORT:-8001}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Docker compose file detection
get_docker_compose_file() {
    if [ -n "$DOCKER_COMPOSE_FILE" ] && [ -f "$DOCKER_COMPOSE_FILE" ]; then
        echo "$DOCKER_COMPOSE_FILE"
        return 0
    fi
    
    # Check common locations
    local possible_files=(
        "docker-compose.yml"
        "docker-compose.yaml"
        "compose.yml"
        "compose.yaml"
        "docker-compose.dev.yml"
        "docker-compose.local.yml"
    )
    
    for file in "${possible_files[@]}"; do
        if [ -f "$file" ]; then
            echo "$file"
            return 0
        fi
    done
    
    return 1
}

# Check Docker installation
test_docker_available() {
    if command -v docker &> /dev/null && docker --version &> /dev/null; then
        return 0
    fi
    return 1
}

# Check Docker Compose installation
test_docker_compose_available() {
    # Try docker compose (v2)
    if docker compose version &> /dev/null 2>&1; then
        echo "docker compose"
        return 0
    fi
    
    # Try docker-compose (v1)
    if command -v docker-compose &> /dev/null && docker-compose --version &> /dev/null 2>&1; then
        echo "docker-compose"
        return 0
    fi
    
    return 1
}

# Get container status
get_container_status() {
    local service_name="$1"
    local compose_file
    local compose_cmd
    
    if ! compose_file=$(get_docker_compose_file); then
        echo '{"status": "no-compose", "message": "No docker-compose file found"}'
        return 1
    fi
    
    if ! compose_cmd=$(test_docker_compose_available); then
        echo '{"status": "no-compose-cli", "message": "Docker Compose not installed"}'
        return 1
    fi
    
    # Check if containers are running
    local ps_output
    if [ -n "$service_name" ] && [ "$service_name" != "all" ]; then
        ps_output=$($compose_cmd -f "$compose_file" ps "$service_name" 2>/dev/null || true)
    else
        ps_output=$($compose_cmd -f "$compose_file" ps 2>/dev/null || true)
    fi
    
    if [ -n "$ps_output" ] && echo "$ps_output" | grep -q "Up\|running"; then
        echo '{"status": "running"}'
        return 0
    else
        echo '{"status": "stopped", "message": "Containers not running"}'
        return 1
    fi
}

# Start Docker containers
start_docker_containers() {
    local service_name="$1"
    
    echo -e "${CYAN}🐳 Starting Docker containers...${NC}"
    
    local compose_file
    if ! compose_file=$(get_docker_compose_file); then
        echo -e "${RED}No docker-compose file found${NC}" >&2
        return 1
    fi
    
    local compose_cmd
    if ! compose_cmd=$(test_docker_compose_available); then
        echo -e "${RED}Docker Compose not installed${NC}" >&2
        return 1
    fi
    
    # Build images if needed
    echo -e "${GRAY}Building Docker images...${NC}"
    if [ -n "$service_name" ] && [ "$service_name" != "all" ]; then
        $compose_cmd -f "$compose_file" build "$service_name"
    else
        $compose_cmd -f "$compose_file" build
    fi
    
    # Start containers
    echo -e "${GRAY}Starting containers...${NC}"
    if [ -n "$service_name" ] && [ "$service_name" != "all" ]; then
        $compose_cmd -f "$compose_file" up -d "$service_name"
    else
        $compose_cmd -f "$compose_file" up -d
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker containers started successfully${NC}"
        
        # Wait for services to be healthy
        sleep 3
        test_service_health
        
        return 0
    fi
    
    return 1
}

# Stop Docker containers
stop_docker_containers() {
    local service_name="$1"
    
    echo -e "${CYAN}🛑 Stopping Docker containers...${NC}"
    
    local compose_file
    if ! compose_file=$(get_docker_compose_file); then
        return 0  # Nothing to stop
    fi
    
    local compose_cmd
    if ! compose_cmd=$(test_docker_compose_available); then
        return 0  # Can't stop without compose
    fi
    
    if [ -n "$service_name" ] && [ "$service_name" != "all" ]; then
        $compose_cmd -f "$compose_file" stop "$service_name"
    else
        $compose_cmd -f "$compose_file" stop
    fi
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker containers stopped${NC}"
        return 0
    fi
    
    return 1
}

# Restart Docker containers
restart_docker_containers() {
    local service_name="$1"
    
    echo -e "${CYAN}🔄 Restarting Docker containers...${NC}"
    
    stop_docker_containers "$service_name"
    sleep 2
    start_docker_containers "$service_name"
}

# Test service health
test_service_health() {
    echo -e "${CYAN}🩺 Checking service health...${NC}"
    
    local healthy=0
    
    # Check frontend health
    if [ -n "$FRONTEND_PORT" ] && [ "$FRONTEND_PORT" != "0" ]; then
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$FRONTEND_PORT" | grep -q "200\|301\|302"; then
            echo -e "${GREEN}✅ Frontend healthy on port $FRONTEND_PORT${NC}"
        else
            echo -e "${YELLOW}⚠️ Frontend not responding on port $FRONTEND_PORT${NC}"
            healthy=1
        fi
    fi
    
    # Check backend health
    if [ -n "$BACKEND_PORT" ] && [ "$BACKEND_PORT" != "0" ]; then
        local health_endpoints=("/health" "/api/health" "/" "/api")
        local backend_healthy=false
        
        for endpoint in "${health_endpoints[@]}"; do
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:$BACKEND_PORT$endpoint" | grep -q "200\|204"; then
                echo -e "${GREEN}✅ Backend healthy on port $BACKEND_PORT${NC}"
                backend_healthy=true
                break
            fi
        done
        
        if [ "$backend_healthy" = false ]; then
            echo -e "${YELLOW}⚠️ Backend not responding on port $BACKEND_PORT${NC}"
            healthy=1
        fi
    fi
    
    return $healthy
}

# View Docker logs
get_docker_logs() {
    local service_name="$1"
    local lines="${2:-50}"
    
    local compose_file
    if ! compose_file=$(get_docker_compose_file); then
        echo -e "${RED}No docker-compose file found${NC}" >&2
        return 1
    fi
    
    local compose_cmd
    if ! compose_cmd=$(test_docker_compose_available); then
        echo -e "${RED}Docker Compose not installed${NC}" >&2
        return 1
    fi
    
    if [ -n "$service_name" ] && [ "$service_name" != "all" ]; then
        $compose_cmd -f "$compose_file" logs --tail="$lines" "$service_name"
    else
        $compose_cmd -f "$compose_file" logs --tail="$lines"
    fi
}

# Execute command in container
invoke_docker_exec() {
    local service_name="$1"
    local command="${2:-sh}"
    
    if [ -z "$service_name" ] || [ "$service_name" = "all" ]; then
        echo -e "${RED}Service name required for exec${NC}" >&2
        return 1
    fi
    
    local compose_file
    if ! compose_file=$(get_docker_compose_file); then
        echo -e "${RED}No docker-compose file found${NC}" >&2
        return 1
    fi
    
    local compose_cmd
    if ! compose_cmd=$(test_docker_compose_available); then
        echo -e "${RED}Docker Compose not installed${NC}" >&2
        return 1
    fi
    
    $compose_cmd -f "$compose_file" exec "$service_name" $command
}

# Clean Docker resources
clear_docker_resources() {
    echo -e "${CYAN}🧹 Cleaning Docker resources...${NC}"
    
    local compose_file
    if compose_file=$(get_docker_compose_file); then
        local compose_cmd
        if compose_cmd=$(test_docker_compose_available); then
            echo -e "${GRAY}Removing containers and networks...${NC}"
            $compose_cmd -f "$compose_file" down
        fi
    fi
    
    # Clean dangling images
    echo -e "${GRAY}Cleaning dangling images...${NC}"
    docker image prune -f
    
    # Clean unused volumes (with confirmation)
    if [ "$FORCE" = "true" ]; then
        echo -e "${GRAY}Cleaning unused volumes...${NC}"
        docker volume prune -f
    fi
    
    echo -e "${GREEN}✅ Docker cleanup complete${NC}"
}

# Troubleshoot Docker issues
invoke_docker_troubleshoot() {
    echo -e "\n${CYAN}🔧 Docker Troubleshooting${NC}"
    echo "=================================================="
    
    # Check Docker daemon
    echo -e "\n${YELLOW}1️⃣ Docker Daemon Status:${NC}"
    if test_docker_available; then
        echo -e "${GREEN}✅ Docker daemon is running${NC}"
        docker version --format "Server: {{.Server.Version}}, Client: {{.Client.Version}}"
    else
        echo -e "${RED}❌ Docker daemon not running${NC}"
        echo -e "${YELLOW}Fix: Start Docker Desktop or run: sudo service docker start${NC}"
    fi
    
    # Check Docker Compose
    echo -e "\n${YELLOW}2️⃣ Docker Compose Status:${NC}"
    if compose_cmd=$(test_docker_compose_available); then
        echo -e "${GREEN}✅ Docker Compose available: $compose_cmd${NC}"
    else
        echo -e "${RED}❌ Docker Compose not installed${NC}"
        echo -e "${YELLOW}Fix: Install with: pip install docker-compose${NC}"
    fi
    
    # Check compose file
    echo -e "\n${YELLOW}3️⃣ Compose File Status:${NC}"
    if compose_file=$(get_docker_compose_file); then
        echo -e "${GREEN}✅ Found: $compose_file${NC}"
    else
        echo -e "${RED}❌ No docker-compose file found${NC}"
        echo -e "${YELLOW}Fix: Create docker-compose.yml in project root${NC}"
    fi
    
    # Check port availability
    echo -e "\n${YELLOW}4️⃣ Port Availability:${NC}"
    for port in $FRONTEND_PORT $BACKEND_PORT; do
        if [ -n "$port" ] && [ "$port" != "0" ]; then
            if nc -z localhost "$port" 2>/dev/null; then
                echo -e "${GREEN}✅ Port $port is accessible${NC}"
            else
                echo -e "${YELLOW}⚠️ Port $port may be blocked or service not running${NC}"
            fi
        fi
    done
    
    # Check disk space
    echo -e "\n${YELLOW}5️⃣ Docker Disk Usage:${NC}"
    docker system df
    
    # Check running containers
    echo -e "\n${YELLOW}6️⃣ Running Containers:${NC}"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    
    # Common fixes
    echo -e "\n${CYAN}💡 Common Fixes:${NC}"
    echo -e "${GRAY}1. Restart Docker: docker-compose restart${NC}"
    echo -e "${GRAY}2. Rebuild images: docker-compose build --no-cache${NC}"
    echo -e "${GRAY}3. View logs: docker-compose logs -f [service]${NC}"
    echo -e "${GRAY}4. Clean resources: docker system prune -a${NC}"
    echo -e "${GRAY}5. Reset completely: docker-compose down -v && docker-compose up -d${NC}"
    
    echo "=================================================="
}

# Main execution
case "$ACTION" in
    start)
        start_docker_containers "$SERVICE"
        ;;
    
    stop)
        stop_docker_containers "$SERVICE"
        ;;
    
    restart)
        restart_docker_containers "$SERVICE"
        ;;
    
    status)
        echo -e "\n${CYAN}🐳 Docker Status for $PROJECT_NAME${NC}"
        echo "=================================================="
        
        if ! test_docker_available; then
            echo -e "${RED}❌ Docker not available${NC}"
            echo -e "${YELLOW}Please install Docker Desktop${NC}"
            exit 1
        fi
        
        status=$(get_container_status)
        if echo "$status" | grep -q '"status": "running"'; then
            echo -e "${GREEN}✅ Containers running${NC}"
            docker ps --format "  - {{.Names}}: {{.State}}"
        else
            message=$(echo "$status" | grep -o '"message": "[^"]*"' | sed 's/"message": "\(.*\)"/\1/')
            echo -e "${YELLOW}⚠️ Containers not running: $message${NC}"
            echo -e "${CYAN}Start with: /bmad:docker start${NC}"
        fi
        
        echo "=================================================="
        ;;
    
    health)
        test_service_health
        ;;
    
    logs)
        get_docker_logs "$SERVICE" 100
        ;;
    
    exec)
        invoke_docker_exec "$SERVICE" "sh"
        ;;
    
    clean)
        clear_docker_resources
        ;;
    
    troubleshoot)
        invoke_docker_troubleshoot
        ;;
    
    build)
        echo -e "${CYAN}🔨 Building Docker images...${NC}"
        if compose_file=$(get_docker_compose_file) && compose_cmd=$(test_docker_compose_available); then
            if [ "$SERVICE" = "all" ]; then
                $compose_cmd -f "$compose_file" build
            else
                $compose_cmd -f "$compose_file" build "$SERVICE"
            fi
        fi
        ;;
    
    *)
        echo -e "${RED}Unknown action: $ACTION${NC}" >&2
        echo "Valid actions: start, stop, restart, status, health, logs, exec, clean, troubleshoot, build"
        exit 1
        ;;
esac