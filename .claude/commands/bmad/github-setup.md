---
description: GitHub integration setup for BMAD-CC - Configure automatic backups and PR creation.
allowed-tools: Bash(git:*), Bash(gh:*), Read, Write
---

# /bmad:github-setup

## AUTOMATIC GITHUB BACKUP CONFIGURATION

This command sets up automatic GitHub backup for your project, ensuring all completed work is pushed to GitHub.

## SETUP PROCESS

### Step 1: Check Prerequisites
```bash
# Check Git installation
git --version
if [ $? -ne 0 ]; then
    echo "âŒ Git not installed. Please install Git first."
    exit 1
fi

# Check GitHub CLI (optional but recommended)
gh --version
if [ $? -ne 0 ]; then
    echo "âš ï¸ GitHub CLI not installed (optional)"
    echo "Install for better integration: https://cli.github.com"
fi
```

### Step 2: Initialize Git Repository
```bash
# Check if already a git repo
if [ ! -d .git ]; then
    echo "ðŸ“ Initializing Git repository..."
    git init
    git add .
    git commit -m "Initial commit from BMAD setup"
else
    echo "âœ… Git repository already initialized"
fi
```

### Step 3: Configure GitHub Authentication
```bash
# Check authentication method
echo "ðŸ” Checking GitHub authentication..."

# Option 1: GitHub CLI (recommended)
if command -v gh &> /dev/null; then
    gh auth status
    if [ $? -ne 0 ]; then
        echo "Authenticating with GitHub..."
        gh auth login
    fi
    
    # Get authenticated user
    GH_USER=$(gh api user --jq '.login')
    echo "âœ… Authenticated as: $GH_USER"
else
    # Option 2: SSH Key
    if [ -f ~/.ssh/id_rsa.pub ] || [ -f ~/.ssh/id_ed25519.pub ]; then
        echo "âœ… SSH keys found"
    else
        echo "âš ï¸ No SSH keys found. You may need to:"
        echo "1. Generate SSH key: ssh-keygen -t ed25519 -C 'your_email@example.com'"
        echo "2. Add to GitHub: https://github.com/settings/keys"
    fi
fi
```

### Step 4: Create/Connect GitHub Repository
```bash
# Get project name for repo
REPO_NAME=$(basename $(pwd))

# Check if remote exists
REMOTE_URL=$(git config --get remote.origin.url)

if [ -z "$REMOTE_URL" ]; then
    echo "ðŸ“¦ No GitHub remote configured"
    
    if command -v gh &> /dev/null; then
        # Use GitHub CLI to create repo
        echo "Creating GitHub repository..."
        
        # Check if repo exists
        gh repo view "$GH_USER/$REPO_NAME" &> /dev/null
        if [ $? -ne 0 ]; then
            # Create new repo
            gh repo create "$REPO_NAME" \
                --private \
                --source=. \
                --remote=origin \
                --description "BMAD-CC - Managed by BMAD"
            
            echo "âœ… Created GitHub repository: $GH_USER/$REPO_NAME"
        else
            # Repo exists, add remote
            gh repo set-default "$GH_USER/$REPO_NAME"
            git remote add origin "https://github.com/$GH_USER/$REPO_NAME.git"
            echo "âœ… Connected to existing repository"
        fi
    else
        echo "Please create repository on GitHub and run:"
        echo "  git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
    fi
else
    echo "âœ… GitHub remote already configured: $REMOTE_URL"
fi
```

### Step 5: Configure Automatic Backup Hook
```bash
# Add backup to post-commit hook
HOOK_FILE=".git/hooks/post-commit"

cat > "$HOOK_FILE" << 'EOF'
#!/bin/sh
# Auto-backup to GitHub after each commit

# Only backup if on main/master branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "ðŸ”„ Auto-backing up to GitHub..."
    git push origin $BRANCH --quiet &
fi
EOF

chmod +x "$HOOK_FILE"
echo "âœ… Automatic backup hook installed"
```

### Step 6: Configure BMAD Workflow Integration
```bash
# Update BMAD settings for GitHub integration
echo "Configuring BMAD GitHub integration..."

# This will be called automatically after task completion
./.claude/hooks/github-backup.ps1 setup
```

## WORKFLOW INTEGRATION

### Automatic Backup Points
The system will automatically backup to GitHub at these points:
1. **After task completion** - When marking task as done
2. **After PR creation** - When creating pull requests
3. **After validation passes** - When quality gates pass
4. **Manual trigger** - Using `/bmad:github-backup` command

### Task-Commit Linking
All commits will include Task Master task IDs:
```bash
git commit -m "feat: implement user auth [task: 23.1]"
# Automatically pushed to GitHub after commit
```

### Pull Request Creation
When completing features:
```bash
# Automatic PR creation with task context
gh pr create \
    --title "feat: User authentication [task: 23]" \
    --body "Implements task 23 from Task Master\n\nTested and validated"
```

## USAGE COMMANDS

### Manual Backup
```bash
# Force backup current state
./.claude/hooks/github-backup.ps1 backup

# Or use the command
/bmad:github-backup
```

### Check Status
```bash
# Check GitHub connection status
./.claude/hooks/github-backup.ps1 status
```

### Push All Branches
```bash
# Push all local branches and tags
./.claude/hooks/github-backup.ps1 push-all
```

## VERIFICATION

### Test the Setup
```bash
echo "ðŸ§ª Testing GitHub integration..."

# Make a test commit
echo "test" > .test-github
git add .test-github
git commit -m "test: GitHub integration"

# Check if auto-pushed
sleep 2
git log origin/$(git rev-parse --abbrev-ref HEAD)..HEAD --oneline

if [ $? -eq 0 ]; then
    echo "âœ… GitHub backup working!"
    rm .test-github
    git rm .test-github
    git commit -m "cleanup: Remove test file"
else
    echo "âš ï¸ Auto-backup may not be working. Check configuration."
fi
```

## TROUBLESHOOTING

### Authentication Issues
```bash
# Reset GitHub CLI auth
gh auth logout
gh auth login

# Check SSH keys
ssh -T git@github.com

# Check git credentials
git config --global credential.helper
```

### Permission Issues
```bash
# Ensure you have push access
gh repo view --json permissions

# Check branch protection
gh api repos/:owner/:repo/branches/main/protection
```

### Connection Issues
```bash
# Test GitHub connectivity
curl -I https://github.com

# Check proxy settings
git config --global --get http.proxy
git config --global --get https.proxy
```

## SUCCESS CRITERIA

âœ… **Setup is complete when:**
- [ ] Git repository initialized
- [ ] GitHub remote configured
- [ ] Authentication working (CLI or SSH)
- [ ] Repository exists on GitHub
- [ ] Auto-backup hook installed
- [ ] Test commit successfully pushed
- [ ] Task Master commits include task IDs

## CONFIGURATION OPTIONS

### Private vs Public Repos
```bash
# Default is private, change if needed
gh repo edit --visibility public
```

### Branch Protection
```bash
# Add branch protection rules
gh api repos/:owner/:repo/branches/main/protection \
    --method PUT \
    --field required_status_checks='{"strict":true,"contexts":[]}' \
    --field enforce_admins=false \
    --field required_pull_request_reviews='{"required_approving_review_count":1}' \
    --field restrictions=null
```

### Backup Frequency
The default is to backup after every commit on main branch. Adjust in `.git/hooks/post-commit` if needed.

Remember: Once configured, all your work is automatically backed up to GitHub, providing version control, collaboration capabilities, and disaster recovery!