# START.md

[English](README.md) | [한국어](README.ko.md)

Set up an AI-assisted project by answering a guided interview. You do not need to edit configuration files by hand or learn the whole workflow first.

Open this folder in your AI tool and say: **"Read START.md and guide me through setup."** The AI asks for your language first, then helps you choose a template, assign AI roles, and check the required tools.

| Folder | Purpose | Entry environment |
|---|---|---|
| [development](development/START.md) | General software development | Claude Code or Codex CLI |
| [game-development](game-development/START.md) | Engine-independent game development | Claude Code or Codex CLI |
| [general-work](general-work/START.md) | Planning, reports, research, and office deliverables | CLI or Codex/Claude desktop |

## Before you start: environment requirements

| Requirement | What you need |
|---|---|
| Operating system | A Windows PC. These templates and helper scripts target Windows; macOS/Linux support is not included. |
| AI entry point | Claude Code or Codex CLI for development. General work can also start in Codex or Claude desktop. A CLI is an AI tool you run in a terminal. |
| Folder access | Give the AI access to the entire local template folder, including permission to write project records. Pasting START.md into a chat alone does not provide that access. |
| PowerShell | PowerShell **7 or later**, available as pwsh, to run the helper scripts. Windows PowerShell 5.1, launched as powershell.exe, is not sufficient. |
| Accounts and models | Sign in to each cloud AI service you select and confirm access to the chosen model. The template does not include accounts, subscriptions, or model access. |
| Network | Internet access for cloud AI calls, sign-in, and any required downloads. Ollama calls need access to the configured Ollama service. |

**You do not need to install every AI tool.** Start with your chosen AI. During setup, it checks the tools needed for your selected roles and explains what is missing.

| Needed only when selected | Additional requirements |
|---|---|
| Codex automation | Codex CLI installed, signed in, and accessible from the Windows execution environment. |
| Claude automation | Claude Code installed and signed in; an available native subagent tool or the supplied CLI adapter handles delegated Claude roles. |
| Gemini automation | A compatible Antigravity agy CLI, signed in with access to the chosen model. The adapter does not target other Gemini CLIs. |
| Ollama | A running Ollama service and the selected model already downloaded. |
| Development or Git-based records | Git and repository access. Development also requires a way to create PRs, such as authenticated GitHub CLI for GitHub. |
| Building software or games | The project's compiler, SDK, engine, dependencies, and test tools, identified during setup. No game engine is bundled. |
| Office deliverables | Tools capable of creating and checking the chosen Word, PowerPoint, Excel, or PDF files. Setup identifies the available tools; a specific office suite is not required by the template. |

For installation and connection details, see the selected template's tool guide: [software](development/guides/TOOLS.md), [games](game-development/guides/TOOLS.md), or [general work](general-work/guides/TOOLS.md). If PowerShell is missing, use [Microsoft's installation guide](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows).

## Start in five steps

### 1. Get the files onto your PC

Download a ZIP from this repository's GitHub page and extract it, or clone the repository with Git. Replace the placeholder below with its current URL:

~~~powershell
git clone "YOUR_REPOSITORY_URL"
~~~

Use the extracted or cloned folder containing this README and the root START.md. If you already have the files locally, use that folder and skip the download.

### 2. Open the folder in your AI tool

Choose one route:

| Your starting point | What to do |
|---|---|
| Codex or Claude Code CLI | Open a terminal in the repository folder, then launch codex or claude. |
| Codex desktop, for general work | Open the repository folder as a local project and start a chat that can access its files. |
| Claude desktop, for general work | Connect the repository folder in a local-file-capable mode and start a chat with folder access. |

For example, if you placed the repository at `C:\Work\AgentTemplate`:

~~~powershell
Set-Location "C:\Work\AgentTemplate"
codex
~~~

Replace the path with your actual folder. To use Claude Code, run claude instead of codex. These commands assume the chosen CLI is already installed.

An app may be able to read local files without being able to run Windows commands. In that case, it can conduct the interview and save a handoff, but full external-agent automation must continue in a capable CLI environment. See the [app guide](general-work/guides/APPS.md).

### 3. Send this message to the AI

Paste this into the **AI conversation**, not directly into the terminal shell:

> Read START.md and guide me through setup. Ask questions one topic at a time. If settings already exist, read them and resume without resetting them.

You do not need to run the helper scripts yourself. The AI follows START.md and runs them when its tools allow it.

### 4. Answer the setup questions

The first question is which language to use for conversation and project documents. You can choose any language the assigned AI supports. The templates stay in English, but subsequent questions, reports, and deliverables use your selected language.

The AI then asks about:

- Which template fits your work: software, games, or general work.
- Whether to copy it for one project or manage several projects in one workspace.
- Your project name, goal, and what a successful result should look like.
- Which AI should coordinate, perform the work, and review it.
- Which skills or MCP connections the work needs, what is already available, and which additions need account access.
- When you want to approve progress and how many reviews you need.

The AI saves your answers as you go. Complete any sign-in or folder-access steps it identifies; it cannot log in on your behalf without the required user interaction.

If you already know which template you want, you can copy only that template folder and start there instead. Keep its LICENSE and hidden files. Each template works independently of the other two.

### 5. Check readiness, then describe your first task

The AI follows the selected template's integration guide to discover relevant skills/MCPs and perform supported installation and configuration within the agreed scope. It guides you through required login, consent, or restart steps and saves where to resume. You do not need to know tool names in advance.

It checks selected agent connections and verifies each required integration in the AI/client that will use it. Missing required capabilities block readiness and non-probe agent calls; optional limitations are recorded. Scripts validate recorded evidence, while the setup AI performs the actual integration checks. Setup cannot install or connect tools that the current environment does not support.

After setup, give it a concrete task, for example:

> Prepare a competitor research report as a Word document. Start by clarifying the scope and proposing a plan.

The AI proposes the plan, agrees the task size with you, and follows the saved review and approval rules. For development tasks, completion goes through a PR; merging remains your action.

## Where your settings and work go

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

## Continue later or switch AI

Open the same folder and ask:

> Read START.md and resume my project using its saved language, settings, and latest handoff.

If several projects exist, name the one you want. The AI reuses recorded answers instead of starting the interview again. Older projects without a language field need one language question; their other settings and records are preserved.

Reusable prompts, guides, and blank forms remain in English. Generated document headings and prose use the selected language. Quotations, code identifiers, file paths, configuration keys, and machine-readable status tokens remain unchanged.

## Included

- Initial interviews, interrupted setup recovery, and handoffs between AI sessions.
- Shared project settings separated from machine-specific paths.
- Task, decision, handoff, and review forms.
- Adapters for Codex CLI, Claude Code role agents, Antigravity agy, and Ollama.
- Call logs, failure states, timeouts, and duplicate-task locking.
- Development completion through commit, push, and PR creation; merging remains with the user.
- Office-file creation and verification guidance for Word, PowerPoint, Excel, and PDF.

The coordinator follows WORKFLOW.md to conduct interviews, advance stages, and assess results. Scripts initialize records, validate configuration, and invoke assigned agents. START.md does not grant file or command access that an app lacks. If an app cannot execute Windows CLIs, the workflow preserves its records and hands off to a CLI environment.

The development AGENTS.md and CLAUDE.md files remain byte-for-byte copies of the original AgentWS files. Additional rules live in separate documents.

## Verification

Live calls, authentication, model availability, and app connections must be checked during setup in the user's environment. Mock verification does not establish live service compatibility.

The latest automated verification ran on **Windows with PowerShell 7.6.5** and passed **123 mock checks**, including skill/MCP readiness and per-consumer evidence checks. It did not invoke live models, install skills, connect live MCP services, or validate desktop app connections.

~~~powershell
pwsh -NoProfile -File ./tests/Verify-Templates.ps1
# Use the fixture path printed by the first command.
pwsh -NoProfile -File ./tests/Verify-Edges.ps1 -Fixture "printed fixture path"
pwsh -NoProfile -File ./tests/Verify-Integrations.ps1 -Fixture "printed fixture path"
~~~
