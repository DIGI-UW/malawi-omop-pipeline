# Visit Detail

The OMOP `VISIT_DETAIL` represents "details of each record in the parent `VISIT_OCURRENCE`" table. In OHDL terms, we translate each `ENCOUNTER` entry into a `VISIT_DETAIL` record. This primarily makes it easier to cross-reference that data loaded into other tables (espeically the `DRUG_EXPOSURE` table in the current setup).
