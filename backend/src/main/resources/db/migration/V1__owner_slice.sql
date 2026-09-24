CREATE TABLE app_user (
 id uuid PRIMARY KEY, phone varchar(16) NOT NULL UNIQUE, name varchar(100) NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE workspace (
 id uuid PRIMARY KEY, name varchar(100) NOT NULL, owner_id uuid NOT NULL UNIQUE REFERENCES app_user(id),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE membership (
 workspace_id uuid NOT NULL REFERENCES workspace(id), user_id uuid NOT NULL REFERENCES app_user(id),
 role varchar(20) NOT NULL CHECK (role='OWNER'), active boolean NOT NULL DEFAULT true,
 PRIMARY KEY(workspace_id,user_id)
);
CREATE TABLE otp_challenge (
 id uuid PRIMARY KEY, phone varchar(16) NOT NULL, expires_at timestamptz NOT NULL,
 attempts integer NOT NULL DEFAULT 0, consumed boolean NOT NULL DEFAULT false,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX otp_phone_created ON otp_challenge(phone,created_at);
CREATE TABLE app_session (
 token_hash varchar(64) PRIMARY KEY, user_id uuid NOT NULL REFERENCES app_user(id),
 csrf_token varchar(64) NOT NULL, expires_at timestamptz NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE equipment (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id),
 reference bigint GENERATED ALWAYS AS IDENTITY, name varchar(100) NOT NULL, model varchar(100) NOT NULL,
 created_by uuid NOT NULL REFERENCES app_user(id), created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id), UNIQUE(workspace_id,reference)
);
CREATE TABLE financial_entry (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id), equipment_id uuid NOT NULL,
 amount numeric(11,2) NOT NULL CHECK(amount>0 AND amount<=999999999.99),
 currency varchar(3) NOT NULL CHECK(currency='SAR'), category varchar(30) NOT NULL,
 operation_date date NOT NULL, note varchar(1000) NOT NULL DEFAULT '',
 lifecycle varchar(20) NOT NULL CHECK(lifecycle='POSTED'),
 created_by uuid NOT NULL REFERENCES app_user(id), created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id), FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id)
);
CREATE TABLE settlement (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id), entry_id uuid NOT NULL,
 amount numeric(11,2) NOT NULL CHECK(amount>0), paid_on date NOT NULL,
 created_by uuid NOT NULL REFERENCES app_user(id), created_at timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY(workspace_id,entry_id) REFERENCES financial_entry(workspace_id,id)
);
CREATE TABLE attachment (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id), entry_id uuid NOT NULL,
 original_name varchar(200) NOT NULL, declared_type varchar(80) NOT NULL, declared_size bigint NOT NULL CHECK(declared_size>0 AND declared_size<=10485760),
 verified_type varchar(80), actual_size bigint, checksum varchar(64), object_key varchar(200),
 state varchar(20) NOT NULL CHECK(state IN ('PENDING','FAILED','READY')),
 scan_status varchar(30) NOT NULL DEFAULT 'DEV_NOT_SCANNED',
 created_by uuid NOT NULL REFERENCES app_user(id), created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id), FOREIGN KEY(workspace_id,entry_id) REFERENCES financial_entry(workspace_id,id)
);
CREATE TABLE idempotency_record (
 workspace_id uuid NOT NULL REFERENCES workspace(id), actor_id uuid NOT NULL REFERENCES app_user(id),
 operation varchar(100) NOT NULL, request_key varchar(100) NOT NULL, payload_hash varchar(64) NOT NULL,
 resource_id uuid NOT NULL, created_at timestamptz NOT NULL DEFAULT now(),
 PRIMARY KEY(workspace_id,actor_id,operation,request_key)
);
CREATE TABLE audit_event (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id), actor_id uuid NOT NULL REFERENCES app_user(id),
 action varchar(80) NOT NULL, resource_id uuid NOT NULL, created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX equipment_workspace_created ON equipment(workspace_id,created_at,id);
CREATE INDEX entry_workspace_created ON financial_entry(workspace_id,created_at,id);
CREATE INDEX attachment_entry ON attachment(workspace_id,entry_id);
