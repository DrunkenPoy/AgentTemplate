# Sharing records between CLI and desktop apps

The two development templates run through CLI. Open Codex or Claude Code in the template folder and ask it to read START.md. Only the general-work template additionally supports the app entry paths below.

## Codex desktop

Open the general-work folder as a local project and ask the AI to read START.md. Verify file access and Windows command execution separately. Recheck machine-specific paths when using another PC or a remote execution environment.

## Claude desktop

Connect the general-work template folder in a mode that can work with local files, then ask the AI to read START.md. Attaching only START.md to a regular chat is not the same as granting access to the working folder.

The app's code execution environment may be separate from the Windows host. Successful file access does not prove that installed Windows CLIs are available. If Windows execution tools are present, use the same scripts. Otherwise continue the interview and document work, then save a handoff for CLI resumption containing:

- Project record location, selected language, and saved answers.
- Completed stages and unperformed Windows connection checks.
- The exact next command.
- Instructions to read the same START.md in a capable Claude Code or Codex CLI environment.

This is an app-to-CLI handoff, not proof that every external AI can run entirely inside the app. Record app capabilities and account/tool limitations in setup-state.json and the setup handoff.

Resume in the saved project language. Keep shared prompt templates in English and do not repeat the language question unless the setting is missing or the user asks to change it.

Consult [Claude's official local-work guide](https://support.claude.com/en/articles/13345190-get-started-with-claude-cowork) for folder access and execution environment details. UI layout can differ by version.
