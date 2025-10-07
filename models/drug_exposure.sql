MODEL (
  name ghii_omop.drug_exposure,
  start '2025-10-07',
  kind FULL,
  grain drug_exposure_id,
  columns (
    drug_exposure_id BIGINT,
    person_id BIGINT,
    drug_concept_id INTEGER,
    drug_exposure_start_date DATE,
    drug_exposure_start_datetime DATETIME,
    drug_exposure_end_date DATE,
    drug_exposure_end_datetime DATETIME,
    verbatim_end_date NVARCHAR(30),
    drug_type_concept_id INTEGER,
    quantity INTEGER,
    route_concept_id INTEGER,
    visit_occurrence_id BIGINT,
    visit_detail_id BIGINT,
    drug_source_value NVARCHAR(50)
  ),
  audits (
    unique_values(columns := (drug_exposure_id)),
    not_null(columns := (
      drug_exposure_id,
      person_id,
      drug_concept_id,
      drug_exposure_start_date,
      drug_type_concept_id
    ))
  )
);

SELECT
  CAST(
    CONCAT(
      o.site_id,
      '8',
      o.order_id
    ) AS INTEGER
  )                           AS drug_exposure_id,
  CAST(
    CONCAT(
      o.site_id,
      '8',
      o.patient_id
    ) AS INTEGER
  )                           AS person_id,
  CASE o.concept_id           -- See the docs for these values
    WHEN 625
      THEN 40079018
    WHEN 628
      THEN 40051187
    WHEN 630
      THEN 40051161
    WHEN 631
      THEN 40072742
    WHEN 633
      THEN 40058384
    WHEN 635
      THEN 40071867
    WHEN 792
      THEN 40173162
    WHEN 794
      THEN 40128015
    WHEN 795
      THEN 40171780
    WHEN 796
      THEN 40032838
    WHEN 797
      THEN 40095223
    WHEN 802
      THEN 40133800
    WHEN 814
      THEN 40097504
    WHEN 954
      THEN 40147739
    WHEN 1610
      THEN 40137867
    WHEN 2203
      THEN 40097200
    WHEN 2833
      THEN 40142130
    WHEN 2985
      THEN 40166595
    WHEN 7927
      THEN 40097202
    WHEN 7928
      THEN 42543871
    WHEN 8729
      THEN 40137867
    WHEN 9232
      THEN 40010552
    WHEN 9234
      THEN 40143571
    WHEN 9525
      THEN 40134454
    WHEN 9543
      THEN 40128015
    WHEN 9662
      THEN 43560390
    WHEN 9939
      THEN 40128015
    ELSE 0                    -- Other drugs have no known mapping
  END                         AS drug_concept_id,
  DATE(o.start_date)          AS drug_exposure_start_date,
  o.start_date                AS drug_exposure_start_datetime,
  IF(
    DATE(
      LEAST(
        COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
        COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
        IF(
          d.quantity is not null and d.quantity >= 1,
          DATE_ADD(
            o.start_date,
            INTERVAL d.quantity - 1 DAY
          ),
          CAST('9999-12-31 23:59:59' AS DATETIME)
        )
      )
    ) < CAST('9999-12-31 23:59:59' AS DATETIME),
    DATE(
      LEAST(
        COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
        COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
        IF(
          d.quantity is not null and d.quantity >= 1,
          DATE_ADD(
            o.start_date,
            INTERVAL d.quantity - 1 DAY
          ),
          CAST('9999-12-31 23:59:59' AS DATETIME)
        )
      )
    ),
    NULL
  )                           AS drug_exposure_end_date,
  IF(
    LEAST(
      COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      IF(
        d.quantity is not null and d.quantity >= 1,
        DATE_ADD(
          o.start_date,
          INTERVAL d.quantity - 1 DAY
        ),
        CAST('9999-12-31 23:59:59' AS DATETIME)
      )
    ) < CAST('9999-12-31 23:59:59' AS DATETIME),
    LEAST(
      COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      IF(
        d.quantity is not null and d.quantity >= 1,
        CAST(DATE_ADD(
          o.start_date,
          INTERVAL d.quantity - 1 DAY
        ) AS DATETIME),
        CAST('9999-12-31 23:59:59' AS DATETIME)
      )
    ),
    NULL
  )                           AS drug_exposure_end_datetime,
  IF(
    LEAST(
      COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME))
    ) < CAST('9999-12-31 23:59:59' AS DATETIME),
    LEAST(
      COALESCE(o.auto_expire_date, CAST('9999-12-31 23:59:59' AS DATETIME)),
      COALESCE(o.discontinued_date, CAST('9999-12-31 23:59:59' AS DATETIME))
    ),
    NULL
  )                           AS verbatim_end_date,
  32833                       AS drug_type_concept_id, -- EHR Order
  d.quantity                  AS quantity,
  4132161                     AS route_concept_id, -- Oral
  vd.visit_occurrence_id      AS visit_occurrence_id,
  CAST(
    CONCAT(
      o.site_id,
      '8',
      o.encounter_id
    ) AS INTEGER
  )                           AS visit_detail_id,
  o.concept_id                AS drug_source_value
FROM
 ohdl.orders o
  JOIN ohdl.concept_set cs
    ON o.concept_id = cs.concept_id
   AND cs.concept_set = 1085  -- 1085 is the set of antiretrovirals
   AND o.concept_id != 106230 -- 106230 is "Positive Re-Test"
  LEFT JOIN ohdl.drug_order d
    ON o.order_id = d.order_id
   AND o.site_id = d.site_id
  JOIN ghii_omop.visit_detail vd
    ON CAST(
      CONCAT(
        o.site_id,
        '8',
        o.encounter_id
      ) AS INTEGER
    ) = vd.visit_detail_id
WHERE
  o.voided = 0;

@IF(
  @runtime_stage = 'evaluating',
  ALTER TABLE @this_model ADD PRIMARY KEY (drug_exposure_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX drug_exposure_person ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX drug_exposure_date ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (drug_exposure_start_date, drug_exposure_end_date)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX drug_exposure_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (drug_exposure_start_datetime, drug_exposure_end_datetime)
);
@IF(
  @runtime_stage = 'evaluating',
  CREATE INDEX drug_exposure_person_id_datetime ON @resolve_template('@{schema_name}.@{table_name}#properties', mode := 'table') (person_id, drug_exposure_start_datetime, drug_exposure_end_datetime)
);
