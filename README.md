# Retrieve_BIP_Phenotypes
Docker container for retrieveing Phenotypic data from the Brassica Information Portal. It runs a ruby script that uses the BIP-API to retrieve
Accession name, Sequence ID, and trait measurements and stores output in .csv-format
The resulting header is as follows:
<Trait>,Seq_id,<Trait_name1>,<Trait_name2>,<Trait_nameN>

based on the TASSEL-5 Phenotype Format. /href{https://bitbucket.org/tasseladmin/tassel-5-source/wiki/UserManual/Load/Load}{ version 4 format}

Sequence IDs get passed on into a Seq_names.txt file for further queries. It also creates a Sequence_IDs_log.txt, where the user can see whether some accessions did not have any or  multiple Sequence IDs.

In case of no Sequence ID's, the Accession is skipped, but recorded in the log.
In case of multiple Sequence ID's, the first Sequence is used for the list of Seq_names and will then be used in subsequent downloads.
