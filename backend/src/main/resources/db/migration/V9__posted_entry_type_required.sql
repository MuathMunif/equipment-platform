-- PostgreSQL CHECK accepts UNKNOWN; V7's shape expression alone does not reject a NULL posted type.
ALTER TABLE financial_entry ADD CONSTRAINT financial_entry_type_by_lifecycle CHECK (
 (lifecycle IN ('DRAFT','DISCARDED') AND entry_type IS NULL)
 OR (lifecycle IN ('POSTED','CANCELLED') AND entry_type IS NOT NULL)
);
