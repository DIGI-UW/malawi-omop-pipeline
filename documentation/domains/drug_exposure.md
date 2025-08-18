# Drug Exposure

This is an important table for calculating whether or not a patient was currently on ART during a period of time. Note that the values we populate in the table are entirely derived from the EHR, and that means that we make a number of assumptions, including that patients take their drugs at the prescribed rate.

## Drug Mappings

The following table documents how each drug order from the "antiretroviral"
concept set is mapped to the OHDSI vocabulary, often called "Athena"

For mappings we make the following assumptions:
- All mappings are for oral tablets of unspecified strength
- All mappings are from RxNorm, ignoring other system
- All mappings are for clinical drug form

The drug names are normalized from OHDL, using a "/" as a separator for
combined products. The OMOP ID corresponds to the concept ID in Athena,
which differs from the RxNorm code.

|Drug                                            |OMOP ID  |OHDL ID |
|------------------------------------------------|---------|--------|
|Stavudine                                       |40079018 |625     |
|Lamivudine                                      |40051187 |628     |
|Zidovudine / Lamivudine                         |40051161 |630     |
|Nevirapine                                      |40072742 |631     |
|Efavirenz                                       |40058384 |633     |
|Nelfinavir                                      |40071867 |635     |
|Stavudine / Lamivudine / Nevirapine             |40173162 |792     |
|Lopinavir / Ritonavir                           |40128015 |794     |
|Ritonavir                                       |40171780 |795     |
|Didanosine*                                     |40032838 |796     |
|Zidovudine                                      |40095223 |797     |
|Tenofovir**                                     |40133800 |802     |
|Abacavir                                        |40097504 |814     |
|Etravirine                                      |40147739 |954     |
|Zidovudine / Lamivudine / Nevirapine            |40137867 |1610    |
|Stavudine / Lamivudine / Efavirenz              |\*\*\*   |1613    |
|Stavudine / Lamivudine / Abacavir               |40097200 |2203    |
|Stavudine / Lamivudine                          |40142130 |2833    |
|Tenofovir / Lamivudine / Efavirenz              |40166595 |2985    |
|Didanosine / Abacavir / Lopinavir / Ritonavir   |\*\*\*   |2988    |
|Zidovudine / Lamivudine / Tenofovir / Lopinavir / Ritonavir|\*\*\*   |6880    |
|Abacavir / Lamivudine                           |40097202 |7927    |
|Tenofovir / Lamivudine                          |42543871 |7928    |
|Tenofovir / Stavudine                           |\*\*\*   |8377    |
|Zidovudine / Lamivudine / Nevirapine\*\*\*\*    |40137867 |8729    |
|Atazanavir / Ritonavir                          |\*\*\*   |9175    |
|Tenofovir / Lamivudine / Atazanavir / Ritonavir |\*\*\*   |9177    |
|Zidovudine / Lamivudine / Atazanavir / Ritonavir|\*\*\*   |9178    |
|Atazanavir                                      |40010552 |9232    |
|Raltegravir\*\*\*\*\*                           |40143571 |9234    |
|Darunavir                                       |40134454 |9525    |
|Lopinavir / Ritonavir\*\*\*\*\*\*               |40128015 |9543    |
|Tenofovir / Lamivudine / Dolutegravir           |\*\*\*   |9671    |
|Dolutegravir                                    |43560390 |9662    |
|Lopinavir / Ritonavir\*\*\*\*\*\*\*             |40128015 |9939    |
|Other antiretroviral                            |**N/A**  |5424    |
|Unknown antiretroviral                          |**N/A**  |5811    |

### Notes

\* Didanosine is coded to "Chewable tablet"
\** Tenofovir is mapped to tenofovir disoproxil as tenofovir alafenamide is less widely available
\*\*\* These are not mappable in Athena
\*\*\*\* Unclear how 8729 differs from 1610; these are mapped identically here
\*\*\*\*\* Raltegravir has a specified strength in OHDL; this is ignored
\*\*\*\*\*\* In OHDL, this is specified as "pellets", but mapped this to "oral tablet"
\*\*\*\*\*\*\* In OHDL, this is specified as "granules", but we've mapped this to "oral tablet"

The code for "Positive Re-test (10684)" included in this concept set is ignored
