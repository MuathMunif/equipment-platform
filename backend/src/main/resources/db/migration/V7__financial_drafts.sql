-- A quick capture becomes the same financial_entry when completed; no zero-value posting.
ALTER TABLE financial_entry ALTER COLUMN amount DROP NOT NULL;
ALTER TABLE financial_entry ALTER COLUMN category DROP NOT NULL;
ALTER TABLE financial_entry ALTER COLUMN operation_date DROP NOT NULL;
ALTER TABLE financial_entry ALTER COLUMN entry_type DROP NOT NULL;
ALTER TABLE financial_entry ADD COLUMN completed_by uuid REFERENCES app_user(id);
ALTER TABLE financial_entry ADD COLUMN completed_at timestamptz;
ALTER TABLE financial_entry ADD COLUMN discarded_by uuid REFERENCES app_user(id);
ALTER TABLE financial_entry ADD COLUMN discarded_at timestamptz;
ALTER TABLE financial_entry DROP CONSTRAINT financial_entry_lifecycle_check;
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_lifecycle_check
 CHECK (lifecycle IN ('DRAFT','POSTED','CANCELLED','DISCARDED'));
ALTER TABLE financial_entry DROP CONSTRAINT financial_entry_cancellation_fields;
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_cancellation_fields CHECK (
 (lifecycle IN ('DRAFT','POSTED','DISCARDED') AND cancellation_reason IS NULL AND cancelled_at IS NULL AND cancelled_by IS NULL)
 OR (lifecycle='CANCELLED' AND cancellation_reason IS NOT NULL AND cancelled_at IS NOT NULL AND cancelled_by IS NOT NULL)
);
ALTER TABLE financial_entry DROP CONSTRAINT financial_entry_scope_equipment_check;
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_shape_check CHECK (
 (lifecycle IN ('DRAFT','DISCARDED') AND equipment_id IS NOT NULL AND amount IS NULL AND category IS NULL
  AND operation_date IS NULL AND entry_type IS NULL AND expense_scope='SINGLE' AND completed_by IS NULL AND completed_at IS NULL)
 OR (lifecycle IN ('POSTED','CANCELLED') AND amount IS NOT NULL AND category IS NOT NULL AND operation_date IS NOT NULL
  AND ((entry_type='INCOME' AND equipment_id IS NOT NULL AND expense_scope='SINGLE')
   OR (entry_type='EXPENSE' AND ((expense_scope='SINGLE' AND equipment_id IS NOT NULL)
    OR (expense_scope IN ('SHARED','GENERAL') AND equipment_id IS NULL))))
  AND ((completed_by IS NULL AND completed_at IS NULL) OR (completed_by IS NOT NULL AND completed_at IS NOT NULL)))
);
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_discard_fields CHECK (
 (lifecycle='DISCARDED' AND discarded_by IS NOT NULL AND discarded_at IS NOT NULL)
 OR (lifecycle<>'DISCARDED' AND discarded_by IS NULL AND discarded_at IS NULL)
);
CREATE INDEX entry_draft_workspace_created ON financial_entry(workspace_id,created_at,id)
 WHERE lifecycle='DRAFT';
