# request-census
Patrick Lavallee Delgado \
Harris School of Public Policy \
University of Chicago \
February 2020

## Overview

Request data from a US Census Bureau API and store in a SQLite database. Look to specifications in a YAML-like file for the endpoints and variables with which to build a table in the database.

The script `request.sh` takes two arguments that identify the locations of the configuration file and the SQLite database, respectively. Only the first is required.

```
$ sh request.sh config.yaml
```

The file `config.yaml` offers the geography by which to request the API, the table in which to store the results, the endpoint for a year in the data, and a mapping of variable codes to readable labels. Note that the file is not actually valid YAML.

The script infers the structure of the destination table from the order of the variable labels in the first call. It creates each column with the storage class NUMERIC. Remember that SQLite uses this as a [type affinity](https://www.sqlite.org/datatype3.html), so we do not need to know the type of the incoming data.

## Future work

A future version of this implementation will aggregate the variables that the configuration file assigns the same label. For example, it would sum variables that represent discrete ages into an age bin.
