# Ledger PL Service

## DONE
* implement invoice -> YAML mapping
* add invoice date to insert gt load
* implement DefaultResource#patch loaded items
* fix bin/*.cmd folder issues

## TODO
* ?

## InsERT/Subiekt error codes
**-2147467259** customer with given customerId/Symbol does not exist

**-2147217527** invoice with this number already exists

## YAML serialization restrictions
* UTF-8 encoding has to be used
* UNIX style end of line (EOL) has to be used ('\n')
* no empty lines are allowed
* all scalars have to be one liners
    - '\n', '\r', '\r' would be serialized as ' '
* single quoutes are used for quoting strings when necessary
* no '\' escaping is used