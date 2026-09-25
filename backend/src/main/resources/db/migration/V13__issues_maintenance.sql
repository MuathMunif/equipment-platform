CREATE TABLE equipment_issue (
 id uuid PRIMARY KEY,
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 equipment_id uuid NOT NULL,
 reference bigint GENERATED ALWAYS AS IDENTITY,
 description varchar(2000) NOT NULL CHECK (length(trim(description))>0),
 type varchar(30) CHECK (type IN ('MECHANICAL','ELECTRICAL','TIRES','ACCIDENT_DAMAGE','OTHER')),
 equipment_stopped boolean NOT NULL DEFAULT false,
 status varchar(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN','IN_PROGRESS','CLOSED')),
 resolution varchar(2000), closed_at timestamptz, closed_by uuid REFERENCES app_user(id),
 created_at timestamptz NOT NULL DEFAULT now(), created_by uuid NOT NULL REFERENCES app_user(id),
 updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id), UNIQUE(workspace_id,reference),
 UNIQUE(workspace_id,id,equipment_id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 CHECK ((status='CLOSED' AND resolution IS NOT NULL AND length(trim(resolution))>0 AND closed_at IS NOT NULL AND closed_by IS NOT NULL) OR status<>'CLOSED')
);
CREATE INDEX issue_equipment_list ON equipment_issue(workspace_id,equipment_id,status,created_at DESC);
CREATE INDEX issue_attention ON equipment_issue(workspace_id,equipment_stopped,created_at DESC) WHERE status='OPEN';

CREATE TABLE issue_closure (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL, issue_id uuid NOT NULL,
 resolution varchar(2000) NOT NULL CHECK(length(trim(resolution))>0),
 closed_at timestamptz NOT NULL, closed_by uuid NOT NULL REFERENCES app_user(id),
 reopened_at timestamptz, reopened_by uuid REFERENCES app_user(id),
 FOREIGN KEY(workspace_id,issue_id) REFERENCES equipment_issue(workspace_id,id)
);
CREATE INDEX issue_closure_history ON issue_closure(workspace_id,issue_id,closed_at DESC);

CREATE TABLE maintenance_record (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id),
 equipment_id uuid NOT NULL, issue_id uuid,
 description varchar(2000) NOT NULL CHECK(length(trim(description))>0),
 maintenance_date date NOT NULL,
 type varchar(30) CHECK(type IN ('REPAIR','PERIODIC_SERVICE','INSPECTION','OTHER')),
 workshop varchar(200),
 cancelled_at timestamptz, cancelled_by uuid REFERENCES app_user(id),
 cancellation_reason varchar(1000),
 created_at timestamptz NOT NULL DEFAULT now(), created_by uuid NOT NULL REFERENCES app_user(id),
 updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 FOREIGN KEY(workspace_id,issue_id,equipment_id) REFERENCES equipment_issue(workspace_id,id,equipment_id),
 CHECK((cancelled_at IS NULL AND cancelled_by IS NULL AND cancellation_reason IS NULL) OR
       (cancelled_at IS NOT NULL AND cancelled_by IS NOT NULL AND cancellation_reason IS NOT NULL AND length(trim(cancellation_reason))>0))
);
CREATE INDEX maintenance_equipment_list ON maintenance_record(workspace_id,equipment_id,maintenance_date DESC,id DESC);
CREATE INDEX maintenance_issue ON maintenance_record(workspace_id,issue_id);

CREATE TABLE maintenance_expense_link (
 workspace_id uuid NOT NULL, maintenance_id uuid NOT NULL, entry_id uuid NOT NULL,
 linked_at timestamptz NOT NULL DEFAULT now(), linked_by uuid NOT NULL REFERENCES app_user(id),
 PRIMARY KEY(workspace_id,entry_id),
 FOREIGN KEY(workspace_id,maintenance_id) REFERENCES maintenance_record(workspace_id,id),
 FOREIGN KEY(workspace_id,entry_id) REFERENCES financial_entry(workspace_id,id)
);
CREATE INDEX maintenance_expense_parent ON maintenance_expense_link(workspace_id,maintenance_id);

ALTER TABLE attachment ADD COLUMN issue_id uuid;
ALTER TABLE attachment ADD COLUMN maintenance_id uuid;
ALTER TABLE attachment DROP CONSTRAINT attachment_one_parent;
ALTER TABLE attachment ADD CONSTRAINT attachment_one_parent CHECK (num_nonnulls(entry_id,document_version_id,issue_id,maintenance_id)=1);
ALTER TABLE attachment ADD CONSTRAINT attachment_issue_fk FOREIGN KEY(workspace_id,issue_id) REFERENCES equipment_issue(workspace_id,id);
ALTER TABLE attachment ADD CONSTRAINT attachment_maintenance_fk FOREIGN KEY(workspace_id,maintenance_id) REFERENCES maintenance_record(workspace_id,id);
CREATE INDEX attachment_issue ON attachment(workspace_id,issue_id);
CREATE INDEX attachment_maintenance ON attachment(workspace_id,maintenance_id);
