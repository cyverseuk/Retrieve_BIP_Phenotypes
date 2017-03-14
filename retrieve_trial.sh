#!/bin/bash

trial_name=$1
api_key=$2

echo "Retrieving Information for trial ${trial_name} from BIP"
#make sure order of inputs is as in .ruby client script:

ls

echo "Start running ruby client"

ruby retrieve_phenotypes_and_ID.rb $trial_name $api_key

echo "Extract sequence identifiers"
cat Phenotypes_BIP_${trial_name}.csv| tr ',' '\t'|awk '{print $1 "," $2}' >> Seq_names.txt

echo "all done"
