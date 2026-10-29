# Start your workflow

Ask the AI: **"Run START.md."**

The AI reading this file must perform these steps:

1. For a new setup, make **language selection the first interview question**, before choosing a template or discussing the project: "Which language would you like to use for our conversation and project documents?" Ask in the language of the user's opening message when clear; otherwise use English. An explicit answer already given in this conversation counts; do not ask again. Continue the interview in the selected language. Read guides/START-MODES.md from any available template (identical across templates); offer Standard start or Quick start with or immediately after the language question. Show its risk notice before Quick start is selected/applied. Carry the selected mode and displayed notice forward; do not repeat them in the selected template.
2. If the user already specified a template or project, use that selection. Otherwise briefly explain these options in the selected language and ask the user to choose:
   - [Software development](development/START.md): general software development, Windows or macOS CLI.
   - [Game development](game-development/START.md): engine-independent game development, Windows or macOS CLI.
   - [General work](general-work/START.md): planning, reports, and research, Windows or macOS CLI or Codex/Claude desktop.
3. In Standard start, confirm whether to copy the selected template to a new location or use it in place. Quick start defaults to using the template in place; honor an explicit copy request. Do not overwrite an existing user folder. Copy the entire template folder, including LICENSE and hidden configuration files.
4. Read and execute the selected folder's START.md, carrying forward the language answer, startup mode, and displayed risk notice without asking again. That folder is the template root; resolve its relative paths and commands there. Persist the language as project.json's language field when initializing the project.
5. Complete environment discovery, the selected mode's interview, workflow-role research and assignments, skill/MCP needs assessment and supported setup, configuration, per-consumer connection checks, and setup handoff. Follow the selected template's guides/INTEGRATIONS.md; perform authorized setup and guide the user through any required login or consent. A setup request alone does not authorize starting an unrelated development or business task.
6. Quick start keeps unused template folders unless cleanup is requested. In Standard start, after the setup handoff is saved, if the selected template is used in place in this repository and the other template folders still exist, offer to set them aside so later sessions do not read them. Explain the choices in the selected language and act only on the user's explicit answer:
   - Archive (recommended): `pwsh -NoProfile -File ./scripts/Set-ActiveTemplate.ps1 -Keep <selected-folder>` zips each unused template folder and tests/ into _archive/ and removes the folders. Restore later with `-Restore <folder>`.
   - Delete: add `-Mode Delete`. Irreversible apart from Git history; the script refuses if a folder contains project records.
   - Keep everything: change nothing.
   Skip this step when the template was copied to a separate location. Never archive or delete the selected template.

When only one template folder remains in the repository root, it is the active template: use it without asking step 2 again. Do not open files in _archive/; if the user wants a different template, restore it first with `./scripts/Set-ActiveTemplate.ps1 -Restore <folder>`.

When resuming an existing project, read its saved language, startup mode, and records first. Older projects without startup records retain Standard start; follow START-MODES.md before changing agent assignments. If several existing projects make the target unclear, resolve the target before changing any setting. Reuse the saved language unless the user asks to change it. For an older project without a language field, ask the language question first and add only that decision; preserve all other answers and files.

Reusable instructions and prompts remain in English. User-facing conversation, project records, handoffs, reviews, and deliverables use the selected language. Keep source quotations, code identifiers, paths, JSON keys, and protocol tokens unchanged. A task-specific language explicitly requested by the user takes precedence for that task and must be recorded.

If file access or writing is unavailable, explain how to connect the folder and identify unperformed steps. Do not claim setup is complete.

See the [README](README.md) for environment requirements and verification limits. Follow the selected template's guides/VALIDATION.md during setup and task verification. The development AGENTS.md and CLAUDE.md files are preserved originals; do not edit them.
