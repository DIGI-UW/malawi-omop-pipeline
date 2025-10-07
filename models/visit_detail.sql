MODEL (
  name ghii_omop.visit_detail,
  start '2025-10-07',
  kind FULL,
  grain visit_detail_id,
  depends_on (ghii_omop.visit_occurrence),
  columns (
    visit_detail_id BIGINT,
    person_id BIGINT,
    visit_detail_concept_id INTEGER,
    visit_detail_start_date DATE,
    visit_detail_start_datetime DATETIME,
    visit_detail_end_date DATE,
    visit_detail_end_datetime DATETIME,
    visit_detail_type_concept_id INTEGER,
    visit_detail_source_value VARCHAR(50),
    preceding_visit_detail_id BIGINT,
    visit_occurrence_id BIGINT,
  ),
  audits(
    unique_values(columns := (visit_detail_id)),
    not_null(columns := (
      visit_detail_id,
      person_id,
      visit_detail_concept_id,
      visit_detail_start_date,
      visit_detail_end_date,
      visit_detail_concept_id,
      visit_detail_type_concept_id
    ))
  )
);

-- We use the visit_detail page to map each encounter. There are two expensive
-- calculations: one to link each visit detail to the preceding detail, which
-- is done with the LAG function, and the other to link the visit detail to its
-- corresponding visit_occurrence
WITH encounters AS (
  SELECT *
  FROM ohdl.encounter e
  WHERE e.voided = 0
)
SELECT
  CAST(
    CONCAT(
      e.site_id,
      '8',
      e.encounter_id
    ) AS INTEGER
  )                           AS visit_detail_id,
  CAST(
    CONCAT(
      e.site_id,
      '8',
      e.patient_id
    ) as INTEGER
  )                           AS person_id,
  9202                        AS visit_detail_concept_id, -- 9202 = Outpatient Visit
  DATE(e.encounter_datetime)  AS visit_detail_start_date,
  e.encounter_datetime        AS visit_detail_start_datetime,
  DATE(e.encounter_datetime)  AS visit_detail_end_date,
  e.encounter_datetime        AS visit_detail_end_datetime,
  32817                       AS visit_detail_type_concept_id, -- 32817 = Came from EHR record
  et.name                     AS visit_detail_source_value,
  CASE
    WHEN LAG(e.encounter_id) OVER w IS NOT NULL
      THEN CAST(
        CONCAT(
          e.site_id,
          '8',
          LAG(e.encounter_id) OVER w
        ) AS INTEGER
      )
      ELSE NULL
  END                        AS preceding_visit_detail_id,
  v.visit_occurrence_id      AS visit_occurrence_id
FROM encounters e
  JOIN ohdl.encounter_type et ON
    e.encounter_type = et.encounter_type_id
  JOIN ghii_omop.visit_occurrence v ON
    CAST(
      CONCAT(
        e.site_id,
        '8',
        e.patient_id
      ) as INTEGER
    ) = v.person_id
  AND
    e.encounter_datetime BETWEEN v.visit_start_datetime AND v.visit_end_datetime
WINDOW w AS (PARTITION BY e.site_id, e.patient_id, DATE(e.encounter_datetime) ORDER BY e.encounter_datetime ASC);

@IF(
  @runtime_stage = 'evaluating',
  ALTER TABLE @this_model ADD PRIMARY KEY (visit_detail_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_detail_person_id ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_detail_date ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (visit_detail_start_date, visit_detail_end_date)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_detail_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (visit_detail_start_datetime, visit_detail_end_datetime)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX visit_detail_person_id_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id, visit_detail_start_datetime, visit_detail_end_datetime)
);
