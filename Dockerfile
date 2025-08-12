# BMAD-CC Framework Development Container
FROM node:20-alpine AS base

# Install system dependencies for Task Master and development tools
RUN apk add --no-cache \
    git \
    bash \
    curl \
    python3 \
    py3-pip \
    make \
    g++ \
    libc6-compat \
    powershell

# Set working directory
WORKDIR /workspace

# Install Task Master AI globally
RUN npm install -g task-master-ai@latest

# Create development user
RUN addgroup --system --gid 1001 bmad && \
    adduser --system --uid 1001 --ingroup bmad bmad

# Copy framework files
COPY --chown=bmad:bmad . .

# Install any Node.js dependencies if package.json exists
RUN if [ -f package.json ]; then npm install; fi

# Set up Task Master working directory
RUN mkdir -p .taskmaster && chown -R bmad:bmad .taskmaster

# Switch to development user
USER bmad

# Expose common development ports
EXPOSE 3000 3001 4000 8000 8080

# Health check to ensure Task Master is working
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD task-master --version || exit 1

# Default command - start an interactive shell for development
CMD ["/bin/bash"]