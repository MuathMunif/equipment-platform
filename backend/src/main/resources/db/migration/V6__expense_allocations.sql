-- The original financial entry remains the only expense and owns its cash movements.
ALTER TABLE financial_entry ALTER COLUMN equipment_id DROP NOT NULL;
ALTER TABLE financial_entry ADD COLUMN expense_scope varchar(10) NOT NULL DEFAULT 'SINGLE'
 CHECK (expense_scope IN ('SINGLE','SHARED','GENERAL'));
CREATE TABLE expense_allocation (
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 entry_id uuid NOT NULL,
 equipment_id uuid NOT NULL,
 amount numeric(11,2) NOT NULL CHECK (amount > 0 AND amount <= 999999999.99),
 PRIMARY KEY (workspace_id,entry_id,equipment_id),
 FOREIGN KEY (workspace_id,entry_id) REFERENCES financial_entry(workspace_id,id),
 FOREIGN KEY (workspace_id,equipment_id) REFERENCES equipment(workspace_id,id)
);
INSERT INTO expense_allocation(workspace_id,entry_id,equipment_id,amount)
 SELECT workspace_id,id,equipment_id,amount FROM financial_entry WHERE entry_type='EXPENSE';
CREATE INDEX expense_allocation_equipment ON expense_allocation(workspace_id,equipment_id,entry_id);
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_scope_equipment_check CHECK (
 (entry_type='INCOME' AND equipment_id IS NOT NULL AND expense_scope='SINGLE') OR
 (entry_type='EXPENSE' AND (
   (expense_scope='SINGLE' AND equipment_id IS NOT NULL) OR
   (expense_scope IN ('SHARED','GENERAL') AND equipment_id IS NULL)
 ))
);
