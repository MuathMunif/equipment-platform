ALTER TABLE financial_entry DROP CONSTRAINT financial_entry_lifecycle_check;
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_lifecycle_check CHECK (lifecycle IN ('POSTED', 'CANCELLED'));
ALTER TABLE financial_entry ADD COLUMN cancellation_reason varchar(500);
ALTER TABLE financial_entry ADD COLUMN cancelled_at timestamptz;
ALTER TABLE financial_entry ADD COLUMN cancelled_by uuid REFERENCES app_user(id);
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_cancellation_fields CHECK (
 (lifecycle = 'POSTED' AND cancellation_reason IS NULL AND cancelled_at IS NULL AND cancelled_by IS NULL)
 OR (lifecycle = 'CANCELLED' AND cancellation_reason IS NOT NULL AND cancelled_at IS NOT NULL AND cancelled_by IS NOT NULL)
);
ALTER TABLE audit_event ADD COLUMN metadata jsonb NOT NULL DEFAULT '{}'::jsonb;
