# get-census
Patrick Lavallee Delgado \
University of Chicago

## Overview

Request data from a US Census Bureau API per specification in a YAML configuration file and store in a SQLite database.

The script `get_census.sh` takes two arguments that identify the locations of the configuration file and the SQLite database, respectively. Only the first is required.

```
$ sh get_census.sh config.yaml
```

The file `config.yaml` offers the geography by which to request the API, the table in which to store the results, the endpoint for the API, and a mapping of variable codes to readable labels by year. Note the endpoint has the placeholder `!!YEAR!!` to represent the year in the data. 

```
geography: tract
table: profile_by_tract
endpoint: https://api.census.gov/data/!!YEAR!!/acs/acs5/profile?
2010: 
  DP05_0065E: population
  DP05_0072PE: white
  DP05_0073PE: black
  DP05_0066PE: hispanic
  DP05_0075PE: asian
```

The configuration is intentionally repetitive to accommodate the annoying occasion when the US Census Bureau reassigns variable codes between annual releases of the data.

The script infers the structure of the destination table from the order of the variable labels in the first call. It creates each column with the storage class NUMERIC. Remember that SQLite uses this as a [type affinity](https://www.sqlite.org/datatype3.html), so we do not need to know the type of the incoming data.

## Future work

A future version of this implementation will aggregate the variables that the configuration file assigns the same label. For example, it would sum variables that represent discrete ages into an age bin. This work would modify `preprocess.awk`.
