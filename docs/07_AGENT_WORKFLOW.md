# Agent delivery workflow
Status: execution proposal supplied with this handoff.

## Roles
Primary session = product/technical delivery lead. Owns plan, requirement consistency, task decomposition, integration and state files.
`implementer` = one bounded code writer, including tests. Does not re-scope product or rewrite unrelated modules.
`reviewer` = independent, initially read-only, reviews a specific diff against acceptance tests and known risks.
`ux_reviewer` = read-only UX reviewer on demand: owner-alone simplicity, Arabic/RTL, desktop/mobile flows and failure states.
Roles are not separate subscriptions. Do not claim to run a model/tool/subagent that the current environment doesn't provide.
If native subagents are unavailable, work sequentially with explicit role/checklist transitions; mark review as non-independent.
A differently named role or separate chat does not make it a security boundary; actual tool permissions govern.

## Model selection
Use the strong coding/reasoning model actually available in the user's current Codex session.
Do not pin model identifiers from old conversations or buy API access automatically.
Increase reasoning for finance/security reviews if the selected model supports it; cheaper agents are optional for narrow read-only work.
Model availability and config keys must be verified against installed Codex and current official documentation.
An optional reviewer in a different vendor's tool requires that tool's actual authorized access; no implicit Claude switch inside Codex.

## Work loop
Lead writes a bounded task with acceptance IDs and out-of-scope items. Designer gives targeted UX advice if needed.
One developer implements; runs tests; returns actual commands/results/diff and remaining gaps.
Independent reviewer sees requirements + diff + relevant source + evidence, not just the developer's success summary.
Review findings include severity, file/line or scenario, expected vs actual, reproduction and suggested bounded fix.
Developer repairs; affected checks rerun; lead updates task, review, decisions and HANDOFF.
Do not start extra agents for tasks that are cheaper and clearer to do in the primary session.

## Parallelism
First slice: one code writer. Read-heavy review/exploration may run separately without writing shared files.
After M1: at most two subordinate threads by the provided initial config; use worktrees for independent writers.
One lead owns shared API contracts/migrations. Allocate task directories and document shared dependencies before delegation.
Worktrees isolate working files, not running ports, databases, buckets or credentials. Give test runs separate namespaces/resources.
Read-only reviewer cannot execute tests that require cache/build writes; it must say NOT RUN and return intended commands.
Actual execution can be performed by the primary, or an explicitly authorized disposable test environment, with attribution.

## Boundaries
No forced resets, deleting user edits, remote push/publish/deploy, secret collection, paid integrations or destructive real-data commands.
No weakening tests, protection settings, authentication or upload scanning just to finish a milestone.
No global Codex configuration changes; project config only after verifying compatibility.
Necessary system installs/out-of-workspace access require the real tool approval. Do not find a bypass through another agent.
Production secrets stay outside prompts/source control. Use explicit isolated local adapters for services awaiting owner setup.

## Stopping and resuming
First delivery target = M0 plus an honest runnable M1. Do not stop after planning if execution is possible.
Do not pretend all V1 is done when only M1 exists. For later work choose the next approved unblocked task from the backlog.
When a session ends or a checkpoint is reached, save state and exact next action in HANDOFF.
After three failed attempts at the same blocker, surface evidence and continue independent authorized work where possible.
No promise that a prompt causes indefinite background execution after the agent stops, the app closes or limits are reached.
