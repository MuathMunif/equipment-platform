-- The owner cannot be deactivated, including through a direct database write.
-- V15 relaxed this to support an older isolation test; that test now revokes a non-owner.
ALTER TABLE membership DROP CONSTRAINT owner_membership_shape;
ALTER TABLE membership ADD CONSTRAINT owner_membership_shape
    CHECK (role <> 'OWNER' OR (active AND scope='ALL_EQUIPMENT' AND financial_mode='DIRECT'));
