#!/bin/bash

echo "Retrieving Information for trial $trial_name from BIP"
#make sure order of inputs is as in .ruby client script:
trial_name=$1
api_key=$2

echo "Start running ruby client"

ruby retrieve_phenotypes_and_ID.rb $trial_name $api_key
echo "all done"
