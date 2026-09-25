ALTER TABLE financial_submission
  ADD COLUMN resubmitted_from_submission_id uuid UNIQUE REFERENCES financial_submission(id);
