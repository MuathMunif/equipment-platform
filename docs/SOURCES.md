# External reference notes
Verified 2026-09-24 for the handoff instructions. Product requirements come from the user's conversation, not these websites.
These sources document Codex features, not proof that a feature/model/SDK is available in the user's installation.
No copied customer correspondence, private employer details or exported entire ChatGPT account history is included.

## Official OpenAI documentation
Projects and chats: distinguishes ChatGPT project context from a local project folder, and explains CLI/IDE scope.
```text
https://learn.chatgpt.com/docs/projects
```
Codex AGENTS.md: repository-scoped guidance is read at session startup; concise reference files are preferable to oversized instructions.
```text
https://learn.chatgpt.com/docs/agent-configuration/agents-md
```
Subagents: role instructions, project-scoped `.codex/agents/*.toml`, required name/description/developer_instructions,
concurrency settings and inherited runtime permissions. Availability depends on actual client/account/configuration.
```text
https://learn.chatgpt.com/docs/agent-configuration/subagents
```
Desktop app: select a local folder/project and a Codex chat.
```text
https://learn.chatgpt.com/docs/app
```
Permissions: workspace boundaries and approval modes. A prompt or role name is not an OS-level permission control.
```text
https://learn.chatgpt.com/docs/permission-modes
```
Cloud: repository-backed environment setup; separate from simply opening a local folder.
```text
https://learn.chatgpt.com/docs/cloud
```
Import: documented importer is for supported external agents (e.g. Claude Code/Cursor); do not present it as a guaranteed
one-click import of this entire ChatGPT project into a writable local code repository.
```text
https://learn.chatgpt.com/docs/import
```
ChatGPT Projects help:
```text
https://help.openai.com/en/articles/10169521-projects-in-chatgpt
```

## Implementation dependency research still required
The target developer must verify actual supported Java/Spring Boot/PostgreSQL/Flutter/storage/FCM versions and APIs from each
vendor's official documentation. This package intentionally does not freeze version numbers, a paid provider, a model ID,
or a claim about current MinIO support based only on a previous conversation.
