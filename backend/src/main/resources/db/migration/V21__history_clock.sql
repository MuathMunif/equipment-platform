-- now() is fixed at transaction start and can precede a committed assignment
-- while a concurrent request waits on the equipment row lock.
ALTER TABLE equipment_organization_assignment ALTER COLUMN started_at SET DEFAULT clock_timestamp();
ALTER TABLE project_equipment_link ALTER COLUMN linked_at SET DEFAULT clock_timestamp();
