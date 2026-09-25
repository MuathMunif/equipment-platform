ALTER TABLE membership DROP CONSTRAINT membership_role_check;
ALTER TABLE membership ADD CONSTRAINT membership_role_check CHECK (role IN ('OWNER','MANAGER','ACCOUNTANT','DRIVER'));
ALTER TABLE membership ADD COLUMN display_name varchar(100);
ALTER TABLE membership ADD COLUMN capabilities text[] NOT NULL DEFAULT '{}';
ALTER TABLE membership ADD COLUMN scope varchar(20) NOT NULL DEFAULT 'ALL_EQUIPMENT' CHECK (scope IN ('ALL_EQUIPMENT','SELECTED_EQUIPMENT','ASSIGNED_EQUIPMENT'));
ALTER TABLE membership ADD COLUMN financial_mode varchar(10) NOT NULL DEFAULT 'DIRECT' CHECK (financial_mode IN ('DIRECT','REVIEW'));
ALTER TABLE membership ADD COLUMN revoked_at timestamptz;
ALTER TABLE membership ADD CONSTRAINT owner_membership_shape CHECK (role <> 'OWNER' OR (active AND scope='ALL_EQUIPMENT' AND financial_mode='DIRECT'));
CREATE TABLE membership_equipment (
 workspace_id uuid NOT NULL, user_id uuid NOT NULL, equipment_id uuid NOT NULL,
 PRIMARY KEY(workspace_id,user_id,equipment_id),
 FOREIGN KEY(workspace_id,user_id) REFERENCES membership(workspace_id,user_id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id)
);
ALTER TABLE app_user ADD COLUMN last_workspace_id uuid REFERENCES workspace(id);

CREATE TABLE workspace_invitation (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id),
 phone varchar(16) NOT NULL, display_name varchar(100) NOT NULL,
 role varchar(20) NOT NULL CHECK(role IN ('MANAGER','ACCOUNTANT','DRIVER')),
 capabilities text[] NOT NULL, scope varchar(20) NOT NULL CHECK(scope IN ('ALL_EQUIPMENT','SELECTED_EQUIPMENT','ASSIGNED_EQUIPMENT')),
 financial_mode varchar(10) NOT NULL CHECK(financial_mode IN ('DIRECT','REVIEW')),
 invited_by uuid NOT NULL REFERENCES app_user(id), created_at timestamptz NOT NULL DEFAULT now(),
 expires_at timestamptz NOT NULL DEFAULT (now()+interval '7 days'),
 status varchar(10) NOT NULL DEFAULT 'PENDING' CHECK(status IN ('PENDING','ACCEPTED','DECLINED','CANCELLED')),
 decided_at timestamptz
);
CREATE UNIQUE INDEX invitation_pending_phone ON workspace_invitation(workspace_id,phone) WHERE status='PENDING';
CREATE TABLE invitation_equipment (
 invitation_id uuid NOT NULL REFERENCES workspace_invitation(id) ON DELETE CASCADE,
 workspace_id uuid NOT NULL, equipment_id uuid NOT NULL,
 PRIMARY KEY(invitation_id,equipment_id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id)
);

CREATE TABLE driver_assignment (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL, driver_user_id uuid NOT NULL,
 equipment_id uuid NOT NULL, started_at timestamptz NOT NULL DEFAULT now(), ended_at timestamptz,
 assigned_by uuid NOT NULL REFERENCES app_user(id),
 FOREIGN KEY(workspace_id,driver_user_id) REFERENCES membership(workspace_id,user_id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id)
);
CREATE UNIQUE INDEX one_active_equipment_per_driver ON driver_assignment(workspace_id,driver_user_id) WHERE ended_at IS NULL;
CREATE UNIQUE INDEX one_active_driver_per_equipment ON driver_assignment(workspace_id,equipment_id) WHERE ended_at IS NULL;

CREATE TABLE financial_submission (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL, equipment_id uuid NOT NULL,
 submitted_by uuid NOT NULL REFERENCES app_user(id), amount numeric(11,2) CHECK(amount>0 AND amount<=999999999.99),
 transaction_date date NOT NULL, note varchar(1000),
 status varchar(20) NOT NULL DEFAULT 'PENDING_REVIEW' CHECK(status IN ('PENDING_REVIEW','APPROVED','REJECTED')),
 submitted_at timestamptz NOT NULL DEFAULT now(), reviewed_by uuid REFERENCES app_user(id), reviewed_at timestamptz,
 rejection_reason varchar(500), approved_financial_entry_id uuid,
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 FOREIGN KEY(workspace_id,approved_financial_entry_id) REFERENCES financial_entry(workspace_id,id),
 CHECK ((status='PENDING_REVIEW' AND reviewed_by IS NULL AND reviewed_at IS NULL AND approved_financial_entry_id IS NULL AND rejection_reason IS NULL)
 OR (status='APPROVED' AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND approved_financial_entry_id IS NOT NULL AND rejection_reason IS NULL)
 OR (status='REJECTED' AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND approved_financial_entry_id IS NULL AND rejection_reason IS NOT NULL))
);
CREATE UNIQUE INDEX one_entry_per_submission ON financial_submission(approved_financial_entry_id) WHERE approved_financial_entry_id IS NOT NULL;
CREATE INDEX submission_queue ON financial_submission(workspace_id,status,submitted_at DESC);
ALTER TABLE financial_entry ADD COLUMN submission_id uuid UNIQUE REFERENCES financial_submission(id);
ALTER TABLE financial_entry ADD COLUMN submitted_by uuid REFERENCES app_user(id);
ALTER TABLE attachment ADD COLUMN submission_id uuid REFERENCES financial_submission(id);
ALTER TABLE attachment DROP CONSTRAINT attachment_one_parent;
ALTER TABLE attachment ADD CONSTRAINT attachment_one_parent CHECK (num_nonnulls(entry_id,document_version_id,issue_id,maintenance_id,submission_id)=1 OR (entry_id IS NOT NULL AND submission_id IS NOT NULL AND document_version_id IS NULL AND issue_id IS NULL AND maintenance_id IS NULL));
CREATE INDEX attachment_submission ON attachment(workspace_id,submission_id);
ALTER TABLE notification DROP CONSTRAINT notification_type_check;
ALTER TABLE notification ADD CONSTRAINT notification_type_check CHECK(type IN ('DOCUMENT_CURRENT_STATE','DOCUMENT_30D','DOCUMENT_7D','DOCUMENT_1D','DOCUMENT_TODAY','DOCUMENT_EXPIRED_WEEKLY','DRIVER_ASSIGNED','DRIVER_ISSUE','SUBMISSION_PENDING','SUBMISSION_APPROVED','SUBMISSION_REJECTED'));
ALTER TABLE notification DROP CONSTRAINT notification_entity_type_check;
ALTER TABLE notification ADD CONSTRAINT notification_entity_type_check CHECK(entity_type IN ('DOCUMENT','DOCUMENT_SUMMARY','EQUIPMENT','ISSUE','FINANCIAL_SUBMISSION'));
ALTER TABLE notification DROP CONSTRAINT notification_check;
ALTER TABLE notification ADD CONSTRAINT notification_entity_shape CHECK((entity_type='DOCUMENT' AND entity_id IS NOT NULL) OR (entity_type='DOCUMENT_SUMMARY' AND entity_id IS NULL) OR entity_type IN ('EQUIPMENT','ISSUE','FINANCIAL_SUBMISSION'));
