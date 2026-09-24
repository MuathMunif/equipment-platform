ALTER TABLE financial_entry ADD COLUMN entry_type varchar(10) NOT NULL DEFAULT 'EXPENSE'
 CHECK (entry_type IN ('EXPENSE','INCOME'));
