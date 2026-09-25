ALTER TABLE equipment ADD COLUMN archived_at timestamptz;
ALTER TABLE equipment ADD COLUMN archived_by uuid REFERENCES app_user(id);

CREATE TABLE equipment_document (
 id uuid PRIMARY KEY,
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 equipment_id uuid NOT NULL,
 type varchar(30) NOT NULL CHECK (type IN ('REGISTRATION','INSURANCE','PERIODIC_INSPECTION','LICENSE_PERMIT','OTHER')),
 custom_type_name varchar(100),
 current_version_id uuid NOT NULL,
 archived_at timestamptz,
 archived_by uuid REFERENCES app_user(id),
 archive_reason varchar(1000),
 created_at timestamptz NOT NULL DEFAULT now(),
 created_by uuid NOT NULL REFERENCES app_user(id),
 UNIQUE(workspace_id,id),
 FOREIGN KEY(workspace_id,equipment_id) REFERENCES equipment(workspace_id,id),
 CHECK ((type='OTHER' AND custom_type_name IS NOT NULL AND length(trim(custom_type_name))>0) OR (type<>'OTHER' AND custom_type_name IS NULL))
);
CREATE INDEX equipment_document_equipment ON equipment_document(workspace_id,equipment_id,archived_at,created_at);

CREATE TABLE document_version (
 id uuid PRIMARY KEY,
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 document_id uuid NOT NULL,
 version_number integer NOT NULL CHECK(version_number>0),
 document_number varchar(100),
 issue_date date,
 expiry_date date,
 notes varchar(1000) NOT NULL DEFAULT '',
 created_at timestamptz NOT NULL DEFAULT now(),
 created_by uuid NOT NULL REFERENCES app_user(id),
 UNIQUE(workspace_id,id),
 UNIQUE(workspace_id,document_id,version_number),
 UNIQUE(workspace_id,document_id,id),
 FOREIGN KEY(workspace_id,document_id) REFERENCES equipment_document(workspace_id,id),
 CHECK(issue_date IS NULL OR expiry_date IS NULL OR issue_date<=expiry_date)
);
ALTER TABLE equipment_document ADD CONSTRAINT document_current_version_fk FOREIGN KEY(workspace_id,id,current_version_id) REFERENCES document_version(workspace_id,document_id,id) DEFERRABLE INITIALLY DEFERRED;

ALTER TABLE attachment ALTER COLUMN entry_id DROP NOT NULL;
ALTER TABLE attachment ADD COLUMN document_version_id uuid;
ALTER TABLE attachment ADD CONSTRAINT attachment_one_parent CHECK ((entry_id IS NOT NULL) <> (document_version_id IS NOT NULL));
ALTER TABLE attachment ADD CONSTRAINT attachment_document_version_fk FOREIGN KEY(workspace_id,document_version_id) REFERENCES document_version(workspace_id,id);
CREATE INDEX attachment_document_version ON attachment(workspace_id,document_version_id);
