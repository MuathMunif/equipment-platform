-- Retention is measured from the last upload attempt, not the initial reservation.
ALTER TABLE attachment ADD COLUMN updated_at timestamptz NOT NULL DEFAULT now();
UPDATE attachment SET updated_at=created_at;
CREATE INDEX attachment_cleanup_pending ON attachment(updated_at,id)
 WHERE state IN ('PENDING','FAILED');
