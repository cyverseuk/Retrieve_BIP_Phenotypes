#!/bin/bash

trial_name=$1
api_key=$2

echo "Retrieving Information for trial ${trial_name} from BIP"
#make sure order of inputs is as in .ruby client script:



echo "Start running ruby client"

ruby /usr/src/app/retrieve_phenotypes_and_ID.rb $trial_name $api_key


echo "creating list of Sequence Identifiers (Seq_names.txt)"


/usr/src/app/ExtractSeqIds.sh ${trial_name}


echo " moving files to output folder"

cp /usr/src/app/*.csv /tmp/
cp /usr/src/app/*.txt /tmp/


echo "done"
