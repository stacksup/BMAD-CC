# Lessons Learned System

This directory contains the BMAD Framework's systematic lessons learned system that captures, organizes, and resurfaces development knowledge.

## Directory Structure

```
docs/lessons/
├── index.md                    # Master lesson catalog and discovery index
├── project-implementation/     # Project-specific technical lessons
├── bmad-workflow/             # BMAD framework improvement lessons
├── technology-patterns/       # Reusable technology solutions
├── troubleshooting/          # Problem resolution lessons
└── templates/                # Lesson capture templates
```

## How Lessons Work

### Automatic Surfacing
Lessons automatically appear during development when:
- **File Context Match**: Working in files that match lesson contexts
- **Agent Role Match**: Current agent matches lesson target audience
- **Keyword Match**: Story/task keywords align with lesson tags
- **Project Type**: Lesson applies to your project type

### Creating Lessons
1. Use templates in `templates/` directory
2. Follow naming convention: `CATEGORY-###-descriptive-title.md`
3. Include rich metadata in YAML frontmatter
4. Update index.md with new lesson entry
5. Update category metadata.json file

## Integration with BMAD Agents

### Learnings Agent
Responsible for:
- Extracting lessons from development experience
- Creating structured lesson documents
- Maintaining lesson quality and consistency
- Updating indexes and metadata

### Other Agents
Enhanced with lesson awareness:
- **System Architect**: Architectural pattern lessons
- **Developer**: Implementation best practices
- **QA Engineer**: Testing patterns and bug recognition
- **All Agents**: Context-aware recommendations

## Success Metrics

### Target Metrics
- **Discovery Time**: <30 seconds to find relevant lessons
- **Application Success**: >85% successful pattern application
- **Time Savings**: 60% reduction vs manual research
- **Knowledge Growth**: 25% productivity improvement per 10 lessons

---

*This system transforms every development challenge into team wisdom, creating compound learning effects that accelerate all future development.*