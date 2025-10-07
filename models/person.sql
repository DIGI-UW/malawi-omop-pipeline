MODEL (
  name ghii_omop.person,
  start '2025-10-07',
  kind FULL,
  grain person_id,
  audits (
    assert_birthdate_is_decomposed,
    assert_all_genders_are_converted,
    unique_values(columns := (person_id, person_source_value)),
    not_null(columns := (
      person_id,
      gender_concept_id,
      race_concept_id,
      ethnicity_concept_id,
      location_id
    ))
  )
);

SELECT
  CAST(
    CONCAT(
      p.site_id,
      '8',
      p.person_id
    ) AS BIGINT
  )                   AS person_id,
  CAST(
    CASE p.gender        -- See https://ohdsi.github.io/Themis/populate_gender_concept_id.html
      WHEN 'M' THEN 8507
      WHEN 'Male' THEN 8507
      WHEN 'F' THEN 8532
      WHEN 'Female' THEN 8532
      ELSE null
    END AS BIGINT
  )                   AS gender_concept_id,
  YEAR(p.birthdate)   AS year_of_birth,
  IF(
    p.birthdate_estimated = 0 OR (
      p.birthdate_estimated = 1 AND
      DAY(p.birthdate) = 15
    ),
    MONTH(p.birthdate),
    NULL
  )                   AS month_of_birth,
  IF(
    p.birthdate_estimated = 0,
    DAY(p.birthdate),
    NULL
  )                   AS day_of_birth,
  IF(
    p.birthdate_estimated = 0, -- In OMOP the field is a datetime, so we cannot store estimated
                               -- birthdates correctly
    p.birthdate
  )                   AS birth_datetime,
  0                   AS race_concept_id, -- Per OMOP, required
  0                   AS ethnicity_concept_id, -- Per OMOP, required
  p.site_id           AS location_id,
  CONCAT(
    p.site_id,
    '-',
    p.person_id
  )                   AS person_source_value,
  p.gender            AS gender_source_value
FROM
  ohdl.person AS p
    JOIN ohdl.patient AS pt
      ON p.person_id = pt.patient_id
     AND p.site_id = pt.site_id
WHERE p.voided = 0;

@IF(
  @runtime_stage = 'evaluating',
  ALTER TABLE @this_model ADD PRIMARY KEY (person_id)
);


AUDIT(
  name assert_birthdate_is_decomposed,
);
-- The purpose of this audit is to ensure that we have no PERSON
-- rows where there was a source birthdate where that isn't decomposed
-- into elements
SELECT *
FROM ghii_omop.person
WHERE (
  year_of_birth IS NULL OR
  month_of_birth IS NULL OR
  day_of_birth IS NULL
) AND birth_datetime IS NOT NULL;

AUDIT(
  name assert_all_genders_are_converted,
);
-- The purpose of this audit is to ensure that we have no PERSON
-- rows where the source data has a gender we have not represented
SELECT *
FROM ghii_omop.person
WHERE gender_concept_id IS NULL AND (
  gender_source_value IS NOT NULL AND
  gender_source_value != 'N/A' AND
  gender_source_Value != ''
);
