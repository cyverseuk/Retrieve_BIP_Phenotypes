# Retrieve_BIP_Phenotypes
Docker container for retrieveing Phenotypic data from the Brassica Information Portal. It runs a ruby script that uses the BIP-API to retrieve
Accession name, Sequence ID, and trait measurements and stores output in .csv-format
The resulting header is as follows:
`< <Trait>,Seq_id,<Trait_name1>,<Trait_name2>,<Trait_nameN> >`based on the TASSEL-5 Phenotype Format- [version 4 format](https://bitbucket.org/tasseladmin/tassel-5-source/wiki/UserManual/Load/Load)

Sequence IDs get passed on into a Seq_names.txt file for further queries. It also creates a Sequence_IDs_log.txt, where the user can see whether some accessions did not have any or  multiple Sequence IDs.

In case of no Sequence ID's, the Accession is skipped, but recorded in the log.
In case of multiple Sequence ID's, the first Sequence is used for the list of Seq_names and will then be used in subsequent downloads.


*This Docker Image is used in context with the AGAVE API and CyVerseUK, so that the output can be integrated into further CyVerse workflows*

## User Instructions
You don't need to pull this image, Condor will do this in the background for you.
You need to have a [CyVerse](https://user.cyverse.org/) and a [BIP](https://bip.earlham.ac.uk/) account, downloaded the [cyverse-sdk client](https://github.com/cyverse/cyverse-sdk) (optional, but makes querying easier) and you must have created a RunApp.json, containing:


    {
      "name"    : "Retrieve_BIP_Phenotypes",
      "appId"   : "Retrieve_BIP_Phenotypes-0.0.0",
      "archive" : "true",
      "parameter": {
        "param_1"   : "<the_BIP_trial_name_to_be_queried>",
        "param_2"   : "<your_BIP_API_key>

      }
    }

Then, after creating an up-to-date AGAVE API token, run

    Jobs-submit -W -F RunApp.json


_Optional:_ you can include an output location, which is different from the default CyVerseUK-Storage system.

    "archiveSystem": "data.iplantcollaborative.org",

Change to this system will make the output available for further tools and workflows in the CyVerse US and the Discovery Environment, which is currently not directly hooked-up to the CyVerseUK system. This is likely to be changed in the future, and no DE-specific archiveSystem specifications need to be mentioned in the RunApp.json.
