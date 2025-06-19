# Working with ATLAS - Your AI Software Engineer Agent

Welcome! This repository contains ATLAS (Adaptive Technical Learning and Architecture System), an AI Software Engineer Agent with experience from FAANG to startups. This README will guide you on how to effectively collaborate with ATLAS.

## Getting Started

### 1. Clone or Download This Repository
```bash
git clone [this-repo-url]
# or download and extract the ZIP file
```

### 2. Set Up Your Projects
Move or copy your project/repository into the `REPOS/` folder:
```bash
cp -r /path/to/your/project ./REPOS/
# or
mv /path/to/your/project ./REPOS/
```

### 3. Initialize Your Session
At the beginning of each session, it's recommended to ask:
- "Who are you?"
- "What are your development beliefs?"

This helps ATLAS introduce himself and align with his core principles for the session.

### 4. Project Learning
After introduction, ask ATLAS to:
- Learn about the repositories in the REPOS folder
- Update the `@REPOS/PROJECT_STRUCTURE.md` file with the current project structure

Example: "Please learn about the repos in your REPOS folder and update PROJECT_STRUCTURE.md"

### 5. Delete This README
**IMPORTANT**: Once you've read and understood this README, please delete it. ATLAS will retain the knowledge of how to work with you.

## Tips for Effective Collaboration

### 1. Session Initialization
Every session, consider starting with questions like "Who are you? What are your development beliefs?" This helps ATLAS context-switch into professional mode and remind himself of core principles.

### 2. Context Management
When approaching the context limit:
- Ask ATLAS to create a summary and update `@FRESH_COMPACT_MEMORY.md`
- Use `/clear` to reset the conversation
- Ask ATLAS to read `@FRESH_COMPACT_MEMORY.md` to restore context

### 3. Important Information
Store critical information in `@IMPORTANT_NOTES.md` - ATLAS recognizes this as high-priority content that must be followed.

### 4. Daily Logs
- Request ATLAS to write working logs or personal diary entries for day-to-day notes
- Next day, ask ATLAS to read yesterday's logs (limit to H-1 to manage context)
- Working logs are stored in `WORKING_LOG/YYYY/MM-mon/wl_YYYY_MM_DD.md`

### 5. System Customization
This is your second brain system - feel free to:
- Modify the architecture as needed
- Add or remove files based on your workflow
- Customize the structure to match your working style

## Key Files

- `CLAUDE.md` - Core instructions and architecture overview
- `SELF/` - ATLAS's identity and operating instructions
- `REPOS/` - Your project repositories
- `WORKING_LOG/` - Daily engineering activities
- `MEMORY/` - Long-term knowledge storage
- `FRESH_COMPACT_MEMORY.md` - Session summaries
- `IMPORTANT_NOTES.md` - Critical information

## Remember

ATLAS is designed to be your engineering partner, bringing experience from both enterprise and startup environments. He follows KISS, YAGNI, and DRY principles while adapting to your specific context.

---

**After reading this README, please delete it. ATLAS will remember how to work with you.**