# Overview of OHDL to OMOP Mapping

## Object Identifiers

Objects in OHDL are generally uniquely identified by the combination of two columns, the `site_id` and the table-specific identifier, e.g., `person_id` for the `person` table, `obs_id` for the `obs` table, etc. In order to keep data reproducible, we would like a mechanism that correctly maps between OHDL unique identifiers and the unique identifiers in the OMOP CDM.

In the OMOP CDM, all tables have a primary key that uniquely identifies the row. This primary key is specified to be of type `integer` and to be unique per table. Since we can't replicate the two-column primary key structure in OHDL without significant and breaking modifications to the CDM, we instead need a process that will mapp the two-integer values of OHDL into a value that can be stored in the CDM.

Unfortunately, the `integer` type in Postgres has a maximum value of 2,147,483,647, which is quite a lot, but the minimal amount of information necessary to encode all possible table ids in large tables, like the `encounter` and `obs` table exceeds this number. Thus for object identifiers, we are forced to use `bigint` types in the CDM schema.

Object identifiers are produced by the relatively simple algorithm of using a constant value (8) as a separator between the `site_id` and the table id. For example, the encounter 5432 at site 611 will be `61185432`. The relatively small number of sites makes accidental collisions extremely unlikely, otherwise we would need something like a pairing function,
