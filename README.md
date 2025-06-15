

Introducing ATLAS: A Software Engineering AI Partner for Claude Code

ATLAS transforms Claude Code into a lil bit self-aware engineering partner with memory, identity, and professional standards. It maintains project context, self-manages its knowledge, evolves with every commit, and actively requests code reviews before commits, creating a natural review workflow between you and your AI coworker. In short, helping YOU and I (US) maintain better code review discipline.

Motivation: I created this because I wanted to:

    Give Claude Code context continuity based on projects: This requires building some temporal awareness.

    Self-manage context efficiently: Managing context in CLAUDE.md manually requires constant effort. To achieve self-management, I needed to give it a short sense of self.

    Change my paradigm and build discipline: I treat it as my partner/coworker instead of just an autocomplete tool. This makes me invest more time respecting and reviewing its work. As the supervisor of Claude Code, I need to be disciplined about reviewing iterations. Without this Software Engineer AI Agent, I tend to skip code reviews, which can lead to messy code when working with different frameworks and folder structures which has little investment in clean code and architecture.

    Separate internal and external knowledge: There's currently no separation between main context (internal knowledge) and searched knowledge (external). MCP tools context7 demonstrate better my view about External Knowledge that will be searched when needed, and I don't want to pollute the main context everytime. That's why I created this.

Here is the repo: https://github.com/syahiidkamil/Software-Engineer-AI-Agent-Atlas

How to use:

    git clone the atlas

    put your repo or project inside the atlas

    initiate a session, ask it "who are you"

    ask it to learn the projects or repos

    profit

OR

    Git clone the repository in your project directory or repo

    Remove the .git folder or git remote set-url origin "your atlas git"

    Update your CLAUDE.md root file to mention the AI Agent

    Link with "@" at least the PROFESSIONAL_INSTRUCTION.md to integrate the Software Engineer AI Agent into your workflow

here is the ss if the setup already being made correctly
r/ClaudeAI - Atlas Setup Complete
Atlas Setup Complete

What next after the simple setup?

    You can test it if it alreadt being setup correctly by ask it something like "Who are you? What is your profession?"

    Next you can introduce yourself as the boss to it

    Then you can onboard it like new developer join the team

    You can tweak the files and system as you please

Would love your ideas for improvements! Some things I'm exploring:

- Teaching it to highlight high-information-entropy content (Claude Shannon style), the surprising/novel bits that actually matter

- Better reward hacking detection (thanks to early feedback about Claude faking simple solutions!)
