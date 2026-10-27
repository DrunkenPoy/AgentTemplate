# Shared workflow rules

## Language

Reusable prompts, operating instructions, and blank forms remain in English. The first setup interview selects project.json's language. Use that language for user-facing conversation, project records, handoffs, review reports, and deliverables. When filling a blank form, localize its headings and prose without editing the distributed English original.

Preserve quotations in their source language, code identifiers, filenames, JSON keys, and protocol tokens. A user's explicit task-specific language instruction takes precedence for that task; record it. Every delegated call, including native subagents, must receive the project language. A missing or blank language requires an interview, not an English or Korean default. On resume, reuse the saved choice; do not translate old records without a request.

## Roles and sources of truth

- Coordinator: interviews, planning, assignments, actual verification, adjudication, Git/completion, and records. Select Claude Code or Codex per project.
- Worker: produce the specified deliverable within the permitted file scope. Do not recursively invoke other agents or perform unassigned Git writes.
- Reviewer: independently check deliverables and each handoff verification request. Report findings with evidence without editing deliverables.
- Ollama: assign its role during the interview. The supplied adapter generates text only. It may draft code or documents, but cannot claim to edit files, build, or verify sources. A capable agent must apply and verify its output and record the result.

project.json holds agreed settings; PROJECT.md holds goals and verification methods; DECISIONS.md holds user decisions; BACKLOG.md holds task state. Put machine-specific paths and commands in project.local.json. Use provider login mechanisms rather than recording keys or tokens.

Before a new task or conversation, read relevant decisions and the latest handoff. Interview the user about conflicting decisions. Do not carry the source game's model names, private paths, or feature rules into unrelated projects.

## Plan the task

1. Add the request to BACKLOG. Copy forms/TASK.md to tasks/<task-id>.md.
2. Specify the goal, scope, exclusions, acceptance criteria, verification methods, dependencies, and affected files/deliverables.
3. Agree small/large task size with the user. Small tasks still require handoffs and review.
4. Obtain confirmation at the checkpoints configured in project.json. Do not repeatedly request permission for execution already covered by the agreed scope.
5. Give the worker the specification, relevant decisions, handoffs, allowed files, and constraints. Write delegation instructions in English; quoted user material and project records may retain their original or selected language.

## Execute, review, and revise

The coordinator runs the following sequence. Invoke-Agent.ps1 invokes a provider and records its response or failure; it does not decide whether requirements have been satisfied.

When Claude Code assigns a Claude worker/reviewer, prefer an available native subagent tool. Pass the selected model and language, task scope, inputs, and reporting format. Store the response in the same handoff/review records. Other coordinators can use the Claude CLI adapter. Native calls do not inherit Invoke-Agent's locking or timeout; the coordinator manages duplicate execution and interruption.

1. Invoke the worker with -Revision 0 for the initial task and 1 through 3 for revisions. Include the task scope and output format.
2. Save its handoff using forms/HANDOFF.md and compare the report with actual changed files.
3. Run real verification: configured builds/tests for development; content, evidence, formatting, and file opening/rendering for office work. Record unperformed checks as unverified.
4. Invoke configured reviewers in order, starting at index 1. Later reviewers receive prior findings and the coordinator's decisions. A worker's self-assessment is not an independent review.
5. Save original findings, the handoff-verification table, and accepted/deferred/rejected decisions with reasons using forms/REVIEW.md. Link deferred findings to follow-up tasks.
6. When revision is needed, send specific findings and evidence to the worker and verify again. Allow at most three complete revision/review cycles; the initial implementation does not count.
7. After three unsuccessful cycles, report unresolved issues, attempts, and options to the user. Do not rename a task to reset the counter.
8. Once all configured reviews and acceptance criteria pass, follow approval checkpoints and completion steps.

~~~powershell
# Send the task request and explicit input materials.
pwsh -NoProfile -File ./scripts/Invoke-Agent.ps1 -Project ./workspace -TaskId example -Phase work -PromptFile ./workspace/tasks/example.md

# First review: provide actual handoff, diff, and verification materials.
pwsh -NoProfile -File ./scripts/Invoke-Agent.ps1 -Project ./workspace -TaskId example-review -Role reviewer -Reviewer 1 -Phase review -PromptFile ./workspace/tasks/example-review.md -InputFiles ./workspace/handoffs/example.md
~~~

The script's responded status means it received a response in the expected format. DONE means the assigned activity finished, not that quality review passed. Never accept BLOCKED/NEEDS_USER, nonzero exits, timeouts, or empty responses as success. Ask whether to wait/retry or change assignments for connection/usage failures; distinguish these from quality revision cycles.

## Handoffs and parallel work

- Small tasks: append stages, authors, and dates to handoffs/<task-id>.md.
- Large tasks: add handoffs/<task-id>/NN-<role>-<stage>.md for each transfer. Do not overwrite previous records.
- Every handoff covers work performed, changed files, actual checks, unchecked items, verification requests, assumptions/limitations, and next steps.
- Reviewers directly check every request and record OK/NG/UNVERIFIED with evidence. Separately identify unsupported claims and changes absent from the handoff.
- Do not advance or finalize a task without required handoff and review records.
- Run tasks in parallel only when independent and their write sets do not overlap. Record file ownership in the plan. Serialize updates to shared settings, BACKLOG, and DECISIONS.
- The script locks concurrent calls for the same TaskId; it does not detect overlapping files across different task IDs. The coordinator must check that.
- Do not concurrently change the Git index, switch branches, or commit in one repository. Use separate checkouts when isolation is necessary and record their locations.

## Completion

### Development

Create a task branch such as codex/<task-name> from the agreed base. Inspect and preserve existing user changes. Do not assume the base is main or develop.

After review, the coordinator commits relevant changes, pushes, and creates a PR. Include the problem, final behavior, actual verification, handoff/review links, and remaining limitations. GitHub projects may use authenticated gh; confirm the correct tool for other hosts during setup. Use a body file for descriptions. **Wait for the user to merge; do not merge automatically.**

If code and operational records live in separate repositories, verify that remote reviewers can access the records. Include accessible links and necessary summaries rather than only local absolute paths. Record the document-sharing approach during setup.

After the user reports a merge, confirm it, archive task records under archive/<task-id>/, and update BACKLOG, DECISIONS, and moved references. Do not arbitrarily delete documents, code, or user material.

### General work

Follow the selected version-control approach. Save final office files under outputs/ or the agreed location and verify opening, content, and layout. Record the recipient, purpose, final location, checks, and limitations in the handoff. External delivery or publication follows the scope agreed during the project interview.

## Interruption and resumption

Record the last completed stage, any running call's result.json, unresolved issues, and next action. Another AI reads START.md and project records, including the saved language, before resuming. After forced termination, inspect a call left in running state and actual file changes before deciding to retry. Do not duplicate a call without checking whether it is still running.
