MODEL (
  name ghii_omop.death,
  start '2025-10-07',
  kind FULL,
  grain person_id,
  audits(
    unique_values(columns := (person_id)),
    not_null(columns := (
      person_id,
      death_date
    ))
  )
);


-- This combines deaths from the patient_state table as well as the person table, even
-- though these data appear to be somewhat redundant, i.e., the deaths recorded in
-- the patient_state table appear to be a superset of those recorded in the person table
WITH deaths as (
  SELECT DISTINCT
    pp.site_id,
    pt.patient_id,
    ps.start_date as death_date
  FROM ohdl.patient_program pp
  JOIN ohdl.person p
    ON pp.patient_id = p.person_id
   AND pp.site_id = p.site_id
   AND p.voided = 0
  JOIN ohdl.patient pt
    ON p.person_id = pt.patient_id
   AND p.site_id = pt.site_id
   AND pt.voided = 0
  JOIN ohdl.patient_state ps
    ON ps.patient_program_id = pp.patient_program_id
   AND ps.site_id = pp.site_id
   AND ps.voided = 0
  JOIN ohdl.program_workflow_state pws
    ON ps.state = pws.program_workflow_state_id
  WHERE pp.voided = 0
    AND pp.program_id = 1      -- Only HIV patients
    AND pws.concept_id = 1742  -- 1742 - Death
)
SELECT
  CAST(
    CONCAT(
      d.site_id,
      '8',
      d.patient_id
    ) AS INTEGER
  )                           AS person_id,
  DATE(d.death_date)          AS death_date,
  d.death_date                AS death_datetime,
  32817                       AS death_type_concept_id  -- 32817 = EHR
FROM deaths d
WHERE d.death_date = (
  SELECT MIN(d2.death_date)
  FROM deaths d2
  WHERE d2.site_id = d.site_id
    AND d2.patient_id = d.patient_id
)
GROUP BY d.site_id, d.patient_id, d.death_date;

@IF(
  @runtime_stage = 'evaluating',
  ALTER TABLE @this_model ADD PRIMARY KEY (person_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX death_date ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (death_date)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX death_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (death_datetime)
);
