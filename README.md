# START.md

**START.md is a workflow template that assigns AI coordination, execution, and review roles and manages project setup, tasks, reviews, and handoffs.**

[English](README.md) | [한국어](README.ko.md)

Use it for software development, game development, and general work on Windows or macOS. It supports cloud AI and Ollama-based local LLMs, and saves your project settings through a guided interview.

[Quick start](#quick-start) · [Requirements](#requirements) · [Local LLMs](#use-a-local-llm) · [Project setup](#project-setup) · [Resume](#resume-your-work) · [Records and folders](#records-and-folders) · [Verification](#verification)

| Folder | Purpose | Entry environment |
|---|---|---|
| [development](development/START.md) | General software development | Claude Code or Codex CLI |
| [game-development](game-development/START.md) | Engine-independent game development | Claude Code or Codex CLI |
| [general-work](general-work/START.md) | Planning, reports, research, and office deliverables | CLI or Codex/Claude desktop |

<details>
<summary>Included features and how it works</summary>

- Initial interviews, interrupted setup recovery, and handoffs between AI sessions.
- Shared project settings separated from machine-specific paths.
- Task, decision, handoff, and review forms.
- Adapters for Codex CLI, Claude Code role agents, Antigravity agy, and Ollama.
- Call logs, failure states, timeouts, and duplicate-task locking.
- Development completion through commit, push, and PR creation; merging remains with the user.
- Office-file creation and verification guidance for Word, PowerPoint, Excel, and PDF.

The coordinator follows WORKFLOW.md to conduct interviews, advance stages, and assess results. Scripts initialize records, validate configuration, and invoke assigned agents. START.md does not grant file or command access that an app lacks. If an app cannot execute local CLIs, the workflow preserves its records and hands off to a CLI environment.

The development AGENTS.md and CLAUDE.md files remain byte-for-byte copies of the original AgentWS files. Additional rules live in separate documents.

</details>

## Quick start

1. Download and extract this repository as a ZIP, or clone it with Git.
2. Launch Codex CLI or Claude Code in the folder containing the root `START.md`. General work can also start in Codex/Claude desktop with local folder access.
3. Say **"Run START.md."** in the AI conversation.
4. Choose your language and Standard start or Quick start. Quick start displays its risks first, uses setup defaults, and automatically assigns needed specialist agents after role research. Standard start keeps the detailed interview and asks approval for additional agents. Existing settings are reused.
5. After tool connections and readiness checks are complete, request your first task.

On Windows, if the repository is at `C:\Work\AgentTemplate`:

~~~powershell
Set-Location "C:\Work\AgentTemplate"
codex
~~~

On macOS, if the repository is at `~/Work/AgentTemplate`:

~~~bash
cd ~/Work/AgentTemplate
codex
~~~

Replace the path with your actual location. The chosen CLI must be installed; run `claude` instead of `codex` for Claude Code. For local models, see [Use a local LLM](#use-a-local-llm).

Send the starting message in the **AI conversation**, not the terminal shell. The AI runs helper scripts through its available tools. If a desktop app cannot run local commands, save the interview and handoff and continue in a CLI. See the [app guide](general-work/guides/APPS.md).

<details>
<summary>Setup questions and tool connections</summary>

### Startup modes

The entry request remains **Run START.md**. **Standard start** keeps the existing interview. **Quick start** (빠른시작) defaults to an in-place single-project setup, inspects available facts, and defers detailed questions until the relevant task. Language, missing project purpose, unresolved base AI choices, approval scope, and indispensable engine/format choices still need answers. A short summary shows applied settings and deferred questions.

Both modes search the workflow and project evidence for needed specialist responsibilities. Standard start asks before adding agents; Quick start automatically assigns justified additions in **all three templates**, using selected providers/models. Before Quick start applies settings or assignments, the AI warns about mistaken assumptions, rework, additional agent usage/cost/time, and task-material sharing with assigned providers. Existing permission limits and verification checks remain in force. See [startup modes](development/guides/START-MODES.md); the same guide is included in every standalone template.

### Setup questions

For new settings, the first question is which language to use for conversation and project documents. Existing settings reuse the saved language. You can choose any language the assigned AI supports. The templates stay in English, but subsequent questions, reports, and deliverables use your selected language.

The AI then asks about the topics below, reusing saved settings where available.

- Which template fits your work: software, games, or general work.
- Whether to copy it for one project or manage several projects in one workspace.
- Your project name, goal, and what a successful result should look like.
- Which AI should coordinate, perform the work, and review it.
- Which skills or MCP connections the work needs, what is already available, and which additions need account access.
- When you want to approve progress and how many reviews you need.

The AI saves your answers as you go. Complete any sign-in or folder-access steps it identifies; it cannot log in on your behalf without the required user interaction.

If you already know which template you want, you can copy only that template folder and start there instead. Keep its LICENSE and hidden files. Each template works independently of the other two.

### Connection checks and your first task

The AI follows the selected template's integration guide to discover relevant skills/MCPs and perform supported installation and configuration within the agreed scope. It guides you through required login, consent, or restart steps and saves where to resume. You do not need to know tool names in advance.

It checks selected agent connections and verifies each required integration in the AI/client that will use it. Missing required capabilities block readiness and non-probe agent calls; optional limitations are recorded. Scripts validate recorded evidence, while the setup AI performs the actual integration checks. Setup cannot install or connect tools that the current environment does not support.

After setup, give it a concrete task, for example:

> Prepare a competitor research report as a Word document. Start by clarifying the scope and proposing a plan.

The AI proposes the plan, agrees the task size with you, and follows the saved review and approval rules. For development tasks, completion goes through a PR; merging remains your action.

</details>

## Requirements

| Requirement | What you need |
|---|---|
| Operating system | Windows or macOS. The helper scripts run on PowerShell 7 on both. Linux is not tested. |
| AI entry point | Claude Code or Codex CLI for development. General work can also start in Codex or Claude desktop. A CLI is an AI tool you run in a terminal. |
| Folder access | Give the AI access to the entire local template folder, including permission to write project records. Pasting START.md into a chat alone does not provide that access. |
| PowerShell | PowerShell **7 or later**, available as pwsh, to run the helper scripts. Windows PowerShell 5.1, launched as powershell.exe, is not sufficient. |
| Accounts and models | Sign in to each cloud AI service you select and confirm access to the chosen model. The template does not include accounts, subscriptions, or model access. |
| Network | Internet access for cloud AI calls, sign-in, and any required downloads. Ollama calls need access to the configured Ollama service. |

**You do not need to install every AI tool.** Start with your chosen AI. During setup, it checks the tools needed for your selected roles and explains what is missing.

<details>
<summary>Additional requirements by tool</summary>

| Needed only when selected | Additional requirements |
|---|---|
| Codex automation | Codex CLI installed and accessible from the local command environment. Cloud models require sign-in; local models require an Ollama connection. |
| Claude automation | Claude Code installed and signed in; an available native subagent tool or the supplied CLI adapter handles delegated Claude roles. |
| Gemini automation | A compatible Antigravity agy CLI, signed in with access to the chosen model. The adapter does not target other Gemini CLIs. |
| Ollama | A running Ollama service and the selected model already downloaded. |
| Development or Git-based records | Git and repository access. Development also requires a way to create PRs, such as authenticated GitHub CLI for GitHub. |
| Building software or games | The project's compiler, SDK, engine, dependencies, and test tools, identified during setup. No game engine is bundled. |
| Office deliverables | Tools capable of creating and checking the chosen Word, PowerPoint, Excel, or PDF files. Setup identifies the available tools; a specific office suite is not required by the template. |

</details>

For installation and connection details, see the selected template's tool guide: [software](development/guides/TOOLS.md), [games](game-development/guides/TOOLS.md), or [general work](general-work/guides/TOOLS.md). If PowerShell is missing, use Microsoft's installation guide for [Windows](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) or [macOS](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos). On macOS with Homebrew: `brew install powershell/tap/powershell`.

## Use a local LLM

**You can also use an Ollama-based local LLM.** A user reported successful operation on macOS with Codex CLI and `gemma4-31b-64k:latest`.

Start the Ollama service and prepare your model, then run the following from the template folder. The model name below is the local tag used in that test; use the name installed in your Ollama environment.

~~~bash
codex --oss -m gemma4-31b-64k:latest -p local-ollama
~~~

`-p local-ollama` selects a previously configured Codex profile. If you do not have that profile, specify Ollama directly:

~~~bash
codex --oss --local-provider ollama -m gemma4-31b-64k:latest
~~~

Then say **"Run START.md."** in the AI conversation. See the [official Codex CLI reference](https://learn.chatgpt.com/docs/developer-commands?surface=cli) for these options.

Using a local model through Codex CLI is separate from the template's direct Ollama adapter. The direct adapter generates responses from supplied text and does not provide file editing or command execution tools. Check each worker/reviewer model and connection during setup.

## Project setup

### New project

Start with an idea. You do not need an empty project folder or Git repository beforehand.

> Run START.md. I have no existing project and want to build a personal task management app.

The AI confirms the matching template and its location, then saves your settings. Actual application or game-engine files are created in the first development task after setup.

If settings for another project already exist, say **"Set up a new project instead of resuming the existing one."** Existing records are preserved.

### Existing project

During setup, give the AI your existing project folder and confirm the working location. Start later sessions from the selected template's START.md so the workflow instructions and saved records are loaded.

## Resume your work

Open the same folder and ask:

> Read START.md and resume my project using its saved language, settings, and latest handoff.

If several projects exist, name the one you want. The AI reuses recorded answers instead of starting the interview again. Older projects without a language field need one language question; their other settings and records are preserved.

Reusable prompts, guides, and blank forms remain in English. Generated document headings and prose use the selected language. Quotations, code identifiers, file paths, configuration keys, and machine-readable status tokens remain unchanged.

## Records and folders

Inside the selected template folder:

| Location | Contents |
|---|---|
| `workspace/` | Records for single-project mode. |
| `projects/<project-id>/` | A separate record folder for each project in multi-project mode. |
| `project.json` | Language, AI assignments, and portable skill/MCP requirements. |
| `project.local.json` | PC paths, connection details and verification evidence; excluded from Git. Credentials stay in the client's credential store. |
| `PROJECT.md`, `DECISIONS.md`, `BACKLOG.md` | Goals, your decisions, and progress. |
| `handoffs/` and `reviews/` | What each agent did, checked, and passed to the next agent. |
| `work/` and `outputs/` | Default working folder and final deliverables. Existing project folders can be used instead. |

The files and subfolders in the last five rows are inside the relevant project's record folder, not necessarily the repository root.

<details>
<summary>Set aside unused templates</summary>

After setup, if you used the template in place, the AI offers to set the other two template folders aside so later sessions only see the one you chose. You can also ask for this at any time.

| Choice | Result |
|---|---|
| Archive (recommended) | Unused template folders and `tests/` are zipped into `_archive/` and removed from the working tree. The AI does not read them. |
| Delete | The folders are removed. This is refused if a folder contains project records. |
| Keep | Nothing changes. |

~~~powershell
pwsh -NoProfile -File ./scripts/Set-ActiveTemplate.ps1 -Keep general-work
# Restore an archived folder later:
pwsh -NoProfile -File ./scripts/Set-ActiveTemplate.ps1 -Restore development
~~~

Add `-WhatIf` to preview. The links to removed folders in this README stop working until they are restored. `_archive/` is excluded from Git.

</details>

## Verification

Live calls, authentication, model availability, and app connections must be checked during setup in the user's environment. Mock verification does not establish live service compatibility.

The latest automated verification ran on **Windows with PowerShell 7.6.5** and passed **189 mock checks**: 89 base, 14 edge, 20 integration, and 66 startup-mode checks. These cover recorded risk disclosure, researched automatic assignments across all three templates, standard-mode role approvals, specialist routing and read-only review, legacy/resume behavior, and required integration checks. They do not prove that a notice was actually shown or that role research was adequate. Tests did not invoke live models, install skills, connect live MCP services, or validate desktop app connections. Separately, a user reported successful macOS execution with Codex CLI and an Ollama local model, as described above. This does not establish that the full automated suite has passed on macOS.

<details>
<summary>Automated verification commands</summary>

~~~powershell
pwsh -NoProfile -File ./tests/Verify-Templates.ps1
# Use the fixture path printed by the first command.
pwsh -NoProfile -File ./tests/Verify-Edges.ps1 -Fixture "printed fixture path"
pwsh -NoProfile -File ./tests/Verify-Integrations.ps1 -Fixture "printed fixture path"
pwsh -NoProfile -File ./tests/Verify-StartupModes.ps1
~~~

</details>
