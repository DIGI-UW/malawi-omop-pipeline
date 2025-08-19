MODEL (
  name ghii_omop.visit_occurrence,
  kind FULL,
  grain visit_occurrence_id,
  audits(
    unique_values(columns := (visit_occurrence_id)),
    not_null(columns := (
      visit_occurrence_id,
      person_id,
      visit_concept_id,
      visit_start_date,
      visit_end_date,
      visit_type_concept_id
    ))
  )
);

-- Since we don't have visits to group encounters, the assumption of
-- this model is that encounters for the same person at the same location
-- on the same day are part of the same visit. In essence, we are treating
-- all encounters as outpatient encounters, which seems consistent with the
-- actual data in the system.
WITH encounters AS (
  SELECT *
  FROM ohdl.encounter e
  WHERE e.voided = 0
), visits AS (
  SELECT
    e.site_id,
    e.patient_id,
    MIN(e.encounter_id)         AS encounter_id,
    DATE(e.encounter_datetime)  AS visit_date,
    MIN(e.encounter_datetime)   AS start_date,
    MAX(e.encounter_datetime)   AS end_date
  FROM encounters e
  GROUP BY e.site_id, e.patient_id, DATE(e.encounter_datetime)
)
SELECT
  CAST(
    CONCAT(
      v.site_id,
      '8',
      v.encounter_id
    ) AS BIGINT
  )                   AS visit_occurrence_id,
  CAST(
    CONCAT(
      v.site_id,
      '8',
      v.patient_id
    ) AS BIGINT
  )                   AS person_id,
  9202                AS visit_concept_id, -- 9202 = Outpatient Visit
  v.visit_date        AS visit_start_date,
  v.start_date        AS visit_start_datetime,
  v.visit_date        AS visit_end_date,
  v.end_date          AS visit_end_datetime,
  32817               AS visit_type_concept_id, -- 32817 = Came from EHR record
  CASE
    WHEN LAG(v.encounter_id) OVER w IS NOT NULL
      THEN CAST(
        CONCAT(
          v.site_id,
          '8',
          LAG(v.encounter_id) OVER w
        ) AS BIGINT
      )
    ELSE
      NULL
  END                 AS preceding_visit_occurrence_id
FROM visits v
GROUP BY
  CAST(
    CONCAT(
      v.site_id,
      '8',
      v.encounter_id
    ) AS BIGINT
  )
WINDOW w AS (PARTITION BY v.site_id, v.patient_id ORDER BY v.start_date ASC);

@IF(
  @runtime_stage = 'evaluating',
  ALTER TABLE @this_model ADD PRIMARY KEY (visit_occurrence_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_occurrence_person_id ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_occurrence_date ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (visit_start_date, visit_end_date)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_occurrence_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (visit_start_datetime, visit_end_datetime)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_occurrence_person_id_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id, visit_start_datetime, visit_end_datetime)
);
