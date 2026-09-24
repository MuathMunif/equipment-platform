CREATE TABLE financial_refund (
 id uuid PRIMARY KEY,
 workspace_id uuid NOT NULL REFERENCES workspace(id),
 entry_id uuid NOT NULL,
 amount numeric(11,2) NOT NULL CHECK (amount > 0 AND amount <= 999999999.99),
 refunded_on date NOT NULL,
 reason varchar(500) NOT NULL CHECK (length(btrim(reason)) > 0),
 created_by uuid NOT NULL REFERENCES app_user(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY (workspace_id, entry_id) REFERENCES financial_entry(workspace_id, id)
);
CREATE INDEX financial_refund_entry_date ON financial_refund(workspace_id, entry_id, refunded_on, created_at);
