# API contracts — to be implemented
No OpenAPI contract has been generated or tested yet.
The delivery lead must create `openapi.yaml` incrementally for each slice and verify implementation against it.
Agree on: request/response schemas, exact money serialization, business dates/instants, lifecycle states,
auth/tenant selection, permission errors, pagination, idempotency/replay and optimistic concurrency conflicts.
Never expose persistence entities or trust client-supplied ownership/approval/calculated values.
Review the contract before independent backend and Flutter agents work in parallel.
