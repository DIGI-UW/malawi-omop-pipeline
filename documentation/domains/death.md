# Death

This table records death events. In OHDL, we derive the fact of patient death from one of two sources:

1. The `patient_state` table indicating that the patient has died
2. The `person` table by looking at either the `dead` or `death_datetime` field

While there is provision in the OMOP `DEATH` table and the OHDL `person` table to record a cause of death,
the `person` table is only used in a minority of cases (221 records out of 493) and the `cause_of_death`
column is always blank.

In any case, cause of death is not a required disaggregate for MERS indicators, but enhancement here is
possible.
