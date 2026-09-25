CREATE TABLE organization (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id),
 name varchar(100) NOT NULL, identifier varchar(100), notes varchar(1000),
 archived_at timestamptz, created_by uuid NOT NULL REFERENCES app_user(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id)
);
CREATE INDEX organization_active_list ON organization(workspace_id,archived_at,created_at DESC);

CREATE TABLE equipment_organization_assignment (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL, equipment_id uuid NOT NULL,
 organization_id uuid NOT NULL, started_at timestamptz NOT NULL DEFAULT now(),
 ended_at timestamptz, assigned_by uuid NOT NULL REFERENCES app_user(id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 FOREIGN KEY(workspace_id,organization_id) REFERENCES organization(workspace_id,id),
 CHECK(ended_at IS NULL OR ended_at>=started_at)
);
CREATE UNIQUE INDEX equipment_one_active_organization ON equipment_organization_assignment(workspace_id,equipment_id) WHERE ended_at IS NULL;
CREATE INDEX equipment_organization_current ON equipment_organization_assignment(workspace_id,organization_id) WHERE ended_at IS NULL;

CREATE TABLE project_or_contract (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL REFERENCES workspace(id),
 kind varchar(10) NOT NULL CHECK(kind IN ('PROJECT','CONTRACT')),
 name varchar(100) NOT NULL, organization_id uuid,
 client_name varchar(100), contract_number varchar(100),
 start_date date, end_date date, notes varchar(1000),
 status varchar(10) NOT NULL DEFAULT 'ACTIVE' CHECK(status IN ('ACTIVE','COMPLETED')),
 archived_at timestamptz, created_by uuid NOT NULL REFERENCES app_user(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(workspace_id,id),
 FOREIGN KEY(workspace_id,organization_id) REFERENCES organization(workspace_id,id),
 CHECK(start_date IS NULL OR end_date IS NULL OR start_date<=end_date)
);
CREATE INDEX project_list ON project_or_contract(workspace_id,archived_at,status,created_at DESC);

CREATE TABLE project_equipment_link (
 id uuid PRIMARY KEY, workspace_id uuid NOT NULL, project_id uuid NOT NULL,
 equipment_id uuid NOT NULL, linked_at timestamptz NOT NULL DEFAULT now(),
 unlinked_at timestamptz, linked_by uuid NOT NULL REFERENCES app_user(id),
 FOREIGN KEY(workspace_id,project_id) REFERENCES project_or_contract(workspace_id,id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 CHECK(unlinked_at IS NULL OR unlinked_at>=linked_at)
);
CREATE UNIQUE INDEX project_one_active_equipment_link ON project_equipment_link(workspace_id,project_id,equipment_id) WHERE unlinked_at IS NULL;
CREATE INDEX project_equipment_history ON project_equipment_link(workspace_id,project_id,linked_at DESC);

ALTER TABLE financial_entry ADD COLUMN project_id uuid;
ALTER TABLE financial_entry ADD CONSTRAINT financial_project_fk FOREIGN KEY(workspace_id,project_id) REFERENCES project_or_contract(workspace_id,id);
CREATE INDEX financial_project ON financial_entry(workspace_id,project_id) WHERE project_id IS NOT NULL;

ALTER TABLE membership DROP CONSTRAINT membership_scope_check;
ALTER TABLE membership ADD CONSTRAINT membership_scope_check CHECK(scope IN ('ALL_EQUIPMENT','SELECTED_EQUIPMENT','SELECTED_ORGANIZATIONS','ASSIGNED_EQUIPMENT'));
ALTER TABLE workspace_invitation DROP CONSTRAINT workspace_invitation_scope_check;
ALTER TABLE workspace_invitation ADD CONSTRAINT workspace_invitation_scope_check CHECK(scope IN ('ALL_EQUIPMENT','SELECTED_EQUIPMENT','SELECTED_ORGANIZATIONS','ASSIGNED_EQUIPMENT'));
CREATE TABLE membership_organization (
 workspace_id uuid NOT NULL, user_id uuid NOT NULL, organization_id uuid NOT NULL,
 PRIMARY KEY(workspace_id,user_id,organization_id),
 FOREIGN KEY(workspace_id,user_id) REFERENCES membership(workspace_id,user_id),
 FOREIGN KEY(workspace_id,organization_id) REFERENCES organization(workspace_id,id)
);
CREATE TABLE invitation_organization (
 invitation_id uuid NOT NULL REFERENCES workspace_invitation(id) ON DELETE CASCADE,
 workspace_id uuid NOT NULL, organization_id uuid NOT NULL,
 PRIMARY KEY(invitation_id,organization_id),
 FOREIGN KEY(workspace_id,organization_id) REFERENCES organization(workspace_id,id)
);

ALTER TABLE attachment ADD COLUMN project_id uuid;
ALTER TABLE attachment ADD CONSTRAINT attachment_project_fk FOREIGN KEY(workspace_id,project_id) REFERENCES project_or_contract(workspace_id,id);
ALTER TABLE attachment DROP CONSTRAINT attachment_one_parent;
ALTER TABLE attachment ADD CONSTRAINT attachment_one_parent CHECK (
 num_nonnulls(entry_id,document_version_id,issue_id,maintenance_id,submission_id,project_id)=1
 OR (entry_id IS NOT NULL AND submission_id IS NOT NULL AND document_version_id IS NULL AND issue_id IS NULL AND maintenance_id IS NULL AND project_id IS NULL));
CREATE INDEX attachment_project ON attachment(workspace_id,project_id);
