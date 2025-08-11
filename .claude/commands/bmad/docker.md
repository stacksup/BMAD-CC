---
description: Docker container management for BMAD-CC - Start, stop, and manage Docker containers for development.
allowed-tools: Bash(docker:*), Bash(docker-compose:*), mcp__docker__list_containers, mcp__docker__list_images, mcp__docker__get_container_logs, mcp__docker__execute_command, mcp__docker__get_container_stats, Read, Write
---

# /bmad:docker

## DOCKER CONTAINER MANAGEMENT

This command manages Docker containers for your project, assuming all development happens in containerized environments.

## QUICK ACTIONS

### Start Development Environment
```bash
# Start all services
./.claude/hooks/docker-manager.ps1 start

# Or using Docker Compose directly
docker-compose up -d

# With build if needed
docker-compose up -d --build
```

### Check Status
```bash
# Check container status
./.claude/hooks/docker-manager.ps1 status

# Or use Docker MCP
mcp__docker__list_containers
```

### View Logs
```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend

# Or use Docker MCP
mcp__docker__get_container_logs --container_id=[container_name] --tail=100
```

## DEVELOPMENT WORKFLOW WITH DOCKER

### 1. Pre-Development Setup
```bash
echo "🐳 Setting up Docker development environment..."

# Ensure Docker is running
docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# Check if docker-compose.yml exists
if [ ! -f "" ] && [ ! -f "docker-compose.yml" ]; then
    echo "⚠️ No docker-compose.yml found. Creating default..."
    # Create based on project type
fi

# Start containers
docker-compose up -d --build
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Health check
curl -f http://localhost:3000 || echo "Frontend not ready"
curl -f http://localhost:8001/health || echo "Backend not ready"
```

### 2. During Development
```bash
# Watch for file changes and rebuild
docker-compose up -d --build

# Execute commands in containers
docker-compose exec backend npm test
docker-compose exec frontend npm run lint

# Database operations
docker-compose exec db psql -U postgres -d BMAD-CC

# Shell access
docker-compose exec backend /bin/bash
docker-compose exec frontend /bin/sh
```

### 3. After Code Changes
```bash
# Rebuild specific service
docker-compose build backend
docker-compose up -d backend

# Restart to apply changes
docker-compose restart backend

# Full rebuild if needed
docker-compose down
docker-compose up -d --build
```

### 4. Testing in Docker
```bash
# Run tests in container
docker-compose exec backend npm test
docker-compose exec backend pytest

# Run integration tests
docker-compose exec test npm run test:integration

# Check test coverage
docker-compose exec backend npm run test:coverage
```

## DOCKER MCP INTEGRATION

### List Containers
Use Docker MCP to get container information:
```
mcp__docker__list_containers
```

### Get Container Logs
```
mcp__docker__get_container_logs --container_id=BMAD-CC_backend_1 --tail=50
```

### Execute Commands
```
mcp__docker__execute_command --container_id=BMAD-CC_backend_1 --command="npm test"
```

### Monitor Resources
```
mcp__docker__get_container_stats --container_id=BMAD-CC_backend_1
```

## TROUBLESHOOTING

### Common Issues & Solutions

#### 1. Port Already in Use
```bash
# Find what's using the port
lsof -i :3000
lsof -i :8001

# Stop conflicting service or change port in docker-compose.yml
```

#### 2. Container Won't Start
```bash
# Check logs
docker-compose logs backend
docker-compose logs frontend

# Rebuild from scratch
docker-compose down -v
docker-compose build --no-cache
docker-compose up -d
```

#### 3. Database Connection Issues
```bash
# Check database is running
docker-compose ps db

# Check network connectivity
docker-compose exec backend ping db

# Verify environment variables
docker-compose exec backend env | grep DATABASE
```

#### 4. File Permission Issues
```bash
# Fix ownership
docker-compose exec backend chown -R node:node /app

# Or run as root temporarily
docker-compose exec -u root backend /bin/bash
```

#### 5. Out of Disk Space
```bash
# Clean up Docker resources
docker system prune -a --volumes

# Check disk usage
docker system df
```

### Debug Mode
```bash
# Run in foreground to see all output
docker-compose up

# Enable debug logging
DEBUG=* docker-compose up

# Inspect container
docker inspect BMAD-CC_backend_1
```

## PROJECT TYPE SPECIFIC CONFIGS

{{#if PROJECT_TYPE.saas}}
### SaaS Project Docker Setup
```yaml
# Typical services for SaaS
services:
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8001
    volumes:
      - ./frontend:/app
      - /app/node_modules
    
  backend:
    build: ./backend
    ports:
      - "8001:8001"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@db:5432/BMAD-CC
      - NODE_ENV=development
    volumes:
      - ./backend:/app
      - /app/node_modules
    depends_on:
      - db
      - redis
    
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=BMAD-CC
      - POSTGRES_PASSWORD=postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    
  redis:
    image: redis:7
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```
{{/if}}

{{#if PROJECT_TYPE.phaser}}
### Phaser Game Docker Setup
```yaml
services:
  game:
    build: .
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev
```
{{/if}}

## HEALTH CHECKS

### Automated Health Monitoring
```bash
# Run health check
./.claude/hooks/docker-manager.ps1 health

# Manual health checks
curl http://localhost:3000
curl http://localhost:8001/health

# Database health
docker-compose exec db pg_isready -U postgres
```

### Container Health Status
```bash
# Check health status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Inspect health check results
docker inspect BMAD-CC_backend_1 --format='{{json .State.Health}}'
```

## DEPLOYMENT PREPARATION

### Build Production Images
```bash
# Build with production settings
docker-compose -f docker-compose.prod.yml build

# Tag images for registry
docker tag BMAD-CC_backend:latest registry.example.com/BMAD-CC/backend:latest
docker tag BMAD-CC_frontend:latest registry.example.com/BMAD-CC/frontend:latest

# Push to registry
docker push registry.example.com/BMAD-CC/backend:latest
docker push registry.example.com/BMAD-CC/frontend:latest
```

## DOCKER COMPOSE COMMANDS REFERENCE

### Essential Commands
- `docker-compose up -d` - Start in background
- `docker-compose down` - Stop and remove containers
- `docker-compose restart` - Restart services
- `docker-compose logs -f` - Follow logs
- `docker-compose exec [service] [command]` - Run command in container
- `docker-compose build` - Build/rebuild images
- `docker-compose ps` - List containers
- `docker-compose top` - Display running processes

### Advanced Commands
- `docker-compose down -v` - Remove with volumes
- `docker-compose build --no-cache` - Rebuild without cache
- `docker-compose up --force-recreate` - Recreate containers
- `docker-compose config` - Validate compose file
- `docker-compose pull` - Pull latest images
- `docker-compose push` - Push images to registry

## INTEGRATION WITH DEVELOPMENT WORKFLOW

### Automatic Container Management
When running `/bmad:smart-cycle` or other workflows:
1. Containers are automatically started if not running
2. Health checks ensure services are ready
3. Tests run inside containers
4. Logs are monitored for errors
5. Containers restart after configuration changes

### Task Completion Integration
```bash
# After task completion
docker-compose exec backend npm test  # Run tests
docker-compose restart  # Apply changes
./.claude/hooks/docker-manager.ps1 health  # Verify health
```

Remember: All development assumes Docker containers. Never install dependencies on host machine - always use containers for isolation and consistency.
