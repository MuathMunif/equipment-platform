ALTER TABLE app_user
 ADD COLUMN preferred_locale varchar(2)
 CHECK (preferred_locale IN ('ar', 'en', 'ur'));

ALTER TABLE notification
 ADD COLUMN template_key varchar(60),
 ADD COLUMN template_params jsonb;

ALTER TABLE notification
 ADD CONSTRAINT notification_template_pair_check
 CHECK ((template_key IS NULL AND template_params IS NULL)
     OR (template_key IS NOT NULL AND template_params IS NOT NULL));

-- Existing development notifications retain title/body and remain readable.
-- New notifications additionally carry semantic template data.
