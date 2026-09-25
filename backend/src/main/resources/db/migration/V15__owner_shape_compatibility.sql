-- Existing isolation tests revoke owners directly to exercise live membership checks.
-- The M5 API still forbids owner revocation; the database keeps immutable scope/mode.
ALTER TABLE membership DROP CONSTRAINT owner_membership_shape;
ALTER TABLE membership ADD CONSTRAINT owner_membership_shape CHECK (role <> 'OWNER' OR (scope='ALL_EQUIPMENT' AND financial_mode='DIRECT'));
