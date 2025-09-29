# Visit Occurrence

The OMOP CDM `VISIT_OCCURRENCE` table relates information on events tables to a single instance which covers:

1. A period of time when the patient is in a health-care facility or
2. A period of time during which the patient is receiving care via a teleconsultation or
3. A period of time during which a patient is receiving care via a home visit

For OHDL, we adopt the simplification that all visits are outpatient visits (i.e., visits to an ambulatory care setting where the patient does not usually stay beyond the clinics working hours). Consequently, we create a `VISIT_OCCURRENCE` entry for each group of OHDL encounters that occur at the same facility with the same patient on the same day. This means that, in effect, `VISIT_OCCURRENCE` entries correspond to one or more OHDL encounters that occur within that defined time window. The `VISIT_OCCURRENCE_ID` is derived from the earliest encounter (ordered by the encounter datetime) in the set of encounters that make up a `VISIT_OCCURRENCE` entry. Likewise, the `VISIT_START_DATETIME` corresponds to the enounter datetime of the earliest encounter and the `VISIT_END_DATETIME` corresponds to the encounter datetime of the latest encounter in the `VISIT_OCCURRENCE`.
