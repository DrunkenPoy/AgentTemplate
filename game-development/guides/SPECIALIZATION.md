# Game development: additional interview and verification

Do not assume a particular engine or game's rules. Inspect the engine, version, and platform settings of an existing project first.

Discuss:

- Engine/version, programming language, platforms, and new/existing project status.
- Core gameplay and acceptance criteria for the requested feature.
- Code, scene, map, and asset locations and permitted modifications.
- Editor, headless build, automated test, and packaging workflows.
- Actual play, input, save/load, visual, and audio verification.
- Repository/base branch, asset versioning, and sharing test results.

Save the engine name in project.json's engine field and paths/commands/versions in PROJECT.md and project.local.json. Use the selected language for project prose while preserving engine identifiers and commands. Do not automatically apply Unreal .uasset restrictions to Unity, Godot, or other projects. Decide binary-asset permissions for this project.

Distinguish a successful build from successful gameplay. Link maps, input, and editor paths outside automated coverage to a user playtest checklist. Check missing tests and new failures against the baseline; do not obtain a pass by weakening or omitting tests.

For visual or presentation changes, prepare screenshots/video and descriptions within the agreed scope and check them against actual behavior. Do not require captures for changes without visual effects. Record environment, conditions, and assumptions for performance and balance measurements.
