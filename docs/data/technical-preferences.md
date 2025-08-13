# Technical Preferences for BMAD-CC

## Project-Specific Configuration
- **Project Type**: Phaser
- **Project Name**: BMAD-CC
{{#if FRONTEND_DIR}}
- **Frontend Directory**: frontend
{{/if}}
{{#if BACKEND_DIR}}
- **Backend Directory**: backend
{{/if}}

## User-Defined Preferred Patterns and Preferences

### Programming Languages
<!-- Specify your preferred languages and versions -->
- **Primary Language**: [e.g., TypeScript, Python, Go]
- **Language Version**: [e.g., TypeScript 5.0+, Python 3.11+]
- **Secondary Languages**: [e.g., SQL, Bash]

### Frameworks & Libraries
<!-- List your preferred frameworks -->
{{#if PROJECT_TYPE.saas}}
#### Frontend
- **UI Framework**: [e.g., React, Vue, Angular]
- **CSS Framework**: [e.g., Tailwind, Material-UI, Bootstrap]
- **State Management**: [e.g., Redux, Zustand, Context API]
- **Form Handling**: [e.g., React Hook Form, Formik]

#### Backend
- **API Framework**: [e.g., Express, FastAPI, Gin]
- **ORM/Database**: [e.g., Prisma, SQLAlchemy, TypeORM]
- **Authentication**: [e.g., JWT, OAuth2, Auth0]
- **Testing**: [e.g., Jest, Pytest, Go test]
{{/if}}

{{#if PROJECT_TYPE.phaser}}
#### Game Development
- **Game Framework**: Phaser 3
- **Build Tool**: [e.g., Webpack, Vite, Parcel]
- **Asset Pipeline**: [e.g., TexturePacker, Aseprite]
- **Physics Engine**: [e.g., Matter.js, Arcade Physics]
{{/if}}

{{#if PROJECT_TYPE.mobile}}
#### Mobile Development
- **Platform**: [e.g., React Native, Flutter, Native]
- **State Management**: [e.g., Redux, MobX, Provider]
- **Navigation**: [e.g., React Navigation, Flutter Navigator]
- **Native Modules**: [List specific needs]
{{/if}}

### Development Practices

#### Code Style
- **Indentation**: [e.g., 2 spaces, 4 spaces, tabs]
- **Quote Style**: [e.g., single quotes, double quotes]
- **Semicolons**: [e.g., always, never, ASI]
- **Line Length**: [e.g., 80, 100, 120 characters]
- **File Naming**: [e.g., kebab-case, camelCase, PascalCase]

#### Architecture Patterns
- **API Style**: [e.g., REST, GraphQL, gRPC]
- **Design Patterns**: [e.g., MVC, MVVM, Clean Architecture]
- **Microservices**: [Yes/No, if yes specify approach]
- **Event-Driven**: [e.g., Message Queue, Event Bus]

#### Testing Strategy
- **Unit Test Coverage Target**: [e.g., 80%, 90%]
- **Test Framework**: [e.g., Jest, Mocha, Pytest]
- **E2E Testing**: [e.g., Cypress, Playwright, Selenium]
- **Mocking Strategy**: [e.g., MSW, Sinon, Mock Service Worker]

### Infrastructure & Deployment

#### Cloud Provider
- **Primary**: [e.g., AWS, GCP, Azure, Vercel]
- **Services Used**: [e.g., EC2, Lambda, S3, RDS]
- **Container Strategy**: [e.g., Docker, Kubernetes, ECS]

#### CI/CD
- **Pipeline Tool**: [e.g., GitHub Actions, GitLab CI, Jenkins]
- **Deployment Strategy**: [e.g., Blue-Green, Canary, Rolling]
- **Environment Stages**: [e.g., dev, staging, prod]

#### Monitoring & Observability
- **APM Tool**: [e.g., DataDog, New Relic, Sentry]
- **Logging**: [e.g., CloudWatch, ELK Stack, Splunk]
- **Metrics**: [e.g., Prometheus, Grafana]

### Database Preferences

#### Primary Database
- **Type**: [e.g., PostgreSQL, MySQL, MongoDB]
- **Version**: [Specify version]
- **Hosting**: [e.g., RDS, Cloud SQL, Self-hosted]

#### Caching
- **Cache Layer**: [e.g., Redis, Memcached]
- **CDN**: [e.g., CloudFront, Cloudflare]

### Security Preferences

#### Authentication & Authorization
- **Method**: [e.g., JWT, Session, OAuth2]
- **Provider**: [e.g., Auth0, Firebase Auth, Custom]
- **MFA**: [Required/Optional]

#### Security Practices
- **Secret Management**: [e.g., AWS Secrets Manager, Vault]
- **Encryption**: [At rest, In transit requirements]
- **Security Headers**: [CSP, HSTS, etc.]

### Performance Requirements

#### Frontend Performance
- **Target Load Time**: [e.g., < 3 seconds]
- **Bundle Size Limit**: [e.g., < 500KB]
- **Lighthouse Score Target**: [e.g., > 90]

#### Backend Performance
- **Response Time Target**: [e.g., < 200ms p95]
- **Concurrent Users**: [Expected load]
- **Rate Limiting**: [Requests per minute]

### Documentation Standards

#### Code Documentation
- **Comment Style**: [e.g., JSDoc, Python docstrings]
- **README Requirements**: [Sections required]
- **API Documentation**: [e.g., OpenAPI/Swagger, Postman]

#### Project Documentation
- **Wiki Tool**: [e.g., Confluence, GitHub Wiki]
- **Diagram Tool**: [e.g., Draw.io, Mermaid, PlantUML]
- **ADR (Architecture Decision Records)**: [Yes/No]

### Team Collaboration

#### Communication Tools
- **Chat**: [e.g., Slack, Discord, Teams]
- **Video**: [e.g., Zoom, Google Meet]
- **Project Management**: [e.g., Jira, Linear, GitHub Projects]

#### Code Review
- **PR Size Preference**: [e.g., < 400 lines]
- **Review Requirements**: [e.g., 2 approvals]
- **Branch Strategy**: [e.g., Git Flow, GitHub Flow]

### Personal Preferences

#### AI Assistant Preferences
- **Explanation Level**: [Detailed/Concise]
- **Code Comments**: [Extensive/Minimal/None]
- **Error Handling Style**: [Explicit/Defensive]

#### Learning & Documentation
- **Prefer Examples**: [Yes/No]
- **Explanation Depth**: [Beginner/Intermediate/Expert]
- **Reference Links**: [Include/Exclude]

## Project-Specific Constraints

### Technical Debt & Legacy
<!-- List any existing technical debt or legacy constraints -->
- [e.g., Must support IE11]
- [e.g., Legacy database schema]
- [e.g., Existing API contracts]

### Compliance Requirements
<!-- List any regulatory or compliance needs -->
- [e.g., GDPR, HIPAA, SOC2]
- [e.g., Accessibility standards (WCAG)]
- [e.g., Industry-specific requirements]

### Performance Constraints
<!-- List any specific performance requirements -->
- [e.g., Must work on 3G networks]
- [e.g., Support 10k concurrent users]
- [e.g., Sub-second response times]

## Notes for AI Agents

### Do's
- Always follow the coding style preferences above
- Use preferred frameworks unless explicitly asked otherwise
- Implement security best practices by default
- Consider performance requirements in all solutions

### Don'ts
- Don't introduce new frameworks without discussion
- Don't ignore established patterns in the codebase
- Don't skip tests to save time
- Don't implement dummy data or fallback patterns (per no-fallback policy)

### When Uncertain
- Ask for clarification on preferences
- Provide options with trade-offs
- Reference this document for consistency
- Suggest updates to this document when patterns emerge

---

*This document should be updated as preferences evolve and patterns are established in the project.*