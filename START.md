# Start your workflow

Ask the AI: **"Read START.md and guide me through setup."**

The AI reading this file must perform these steps:

1. For a new setup, make **language selection the first interview question**, before choosing a template or discussing the project: "Which language would you like to use for our conversation and project documents?" Ask in the language of the user's opening message when clear; otherwise use English. An explicit answer already given in this conversation counts; do not ask again. Continue the interview in the selected language.
2. If the user already specified a template or project, use that selection. Otherwise briefly explain these options in the selected language and ask the user to choose:
   - [Software development](development/START.md): general software development, Windows CLI.
   - [Game development](game-development/START.md): engine-independent game development, Windows CLI.
   - [General work](general-work/START.md): planning, reports, and research, Windows CLI or Codex/Claude desktop.
3. Confirm whether to copy the selected template to a new location or use it in place. Do not overwrite an existing user folder. Copy the entire template folder, including LICENSE and hidden configuration files.
4. Read and execute the selected folder's START.md, carrying forward the language answer without asking again. That folder is the template root; resolve its relative paths and commands there. Persist the language as project.json's language field when initializing the project.
5. Complete environment discovery, the topic-by-topic interview, configuration, connection checks, and setup handoff. A setup request alone does not authorize starting an unrelated development or business task.

When resuming an existing project, read its saved language and records first. If several existing projects make the target unclear, resolve the target before changing any setting. Reuse the saved language unless the user asks to change it. For an older project without a language field, ask the language question first and add only that decision; preserve all other answers and files.

Reusable instructions and prompts remain in English. User-facing conversation, project records, handoffs, reviews, and deliverables use the selected language. Keep source quotations, code identifiers, paths, JSON keys, and protocol tokens unchanged. A task-specific language explicitly requested by the user takes precedence for that task and must be recorded.

If file access or writing is unavailable, explain how to connect the folder and identify unperformed steps. Do not claim setup is complete.

See the [README](README.md) for environment requirements and verification limits. Follow the selected template's guides/VALIDATION.md during setup and task verification. The development AGENTS.md and CLAUDE.md files are preserved originals; do not edit them.
