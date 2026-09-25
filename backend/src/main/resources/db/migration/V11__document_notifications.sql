CREATE TABLE notification (
 id uuid PRIMARY KEY,
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 recipient_user_id uuid NOT NULL REFERENCES app_user(id),
 type varchar(40) NOT NULL CHECK(type IN ('DOCUMENT_CURRENT_STATE','DOCUMENT_30D','DOCUMENT_7D','DOCUMENT_1D','DOCUMENT_TODAY','DOCUMENT_EXPIRED_WEEKLY')),
 entity_type varchar(30) NOT NULL CHECK(entity_type IN ('DOCUMENT','DOCUMENT_SUMMARY')),
 entity_id uuid,
 title varchar(200) NOT NULL,
 body varchar(500) NOT NULL,
 dedupe_key varchar(200) NOT NULL,
 read_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,recipient_user_id,dedupe_key),
 FOREIGN KEY(workspace_id,recipient_user_id) REFERENCES membership(workspace_id,user_id),
 CHECK((entity_type='DOCUMENT' AND entity_id IS NOT NULL) OR (entity_type='DOCUMENT_SUMMARY' AND entity_id IS NULL))
);
CREATE INDEX notification_recipient_page ON notification(workspace_id,recipient_user_id,created_at DESC,id DESC);
CREATE INDEX notification_recipient_unread ON notification(workspace_id,recipient_user_id) WHERE read_at IS NULL;
