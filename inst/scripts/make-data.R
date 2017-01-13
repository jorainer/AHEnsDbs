## Describe here how the data files where/are created.
## Creation of the EnsDb sqlite files will be performed manually by me with
## each new release.

## Requirements:
## o Perl
## o Ensembl Perl API corresponding to the version for which the databases should
##   be created. See http://www.ensembl.org/info/docs/api/api_installation.html
##   for more details.
## o BioPerl.
## o MySQL server with access credentials allowing to create databases and insert
##   data.
##
## Description:
## Needs the Ensembl Perl API and BioPerl to be installed as well as a local
## MySQL server on which temporarily the Ensembl core database will be installed.
## Generation of EnsDb SQLite databases are generated using the
## `createEnsDbForSpecies` function in the generate-EnsDbs.R script available in
## the inst/scripts folder of the ensembldb package.
## This function first connects to the Ensembl ftp server and fetches the names
## of all species for which an Ensembl core database is available. Subsequently
## it processes all species by
## 1) Downloading the MySQL core database dump for the species.
## 2) Locally install this MySQL database
## 3) Using the corresponding functions of the ensembldb package extract all
##    relevant data from this database and generate the EnsDb SQLite file. The
##    R functions use a perl script from the ensembldb package to fetch the data
##    using the Ensembl Perl API.
##
## Notes: it would be possible to create all databases by directly querying the
## core database directly from Ensembl, but installing local MySQL instances has
## been proven to be faster and a more reliable solution.

