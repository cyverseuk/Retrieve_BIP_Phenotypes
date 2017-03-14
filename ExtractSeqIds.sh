#!/bin/bash


trial_name=$1

while read line
do
  var=$(echo $line | tr ',' '\t' | awk '{print $2}')

##retrieve sequences
  if [ "${var:0:1}" != "S" ]; then
  var2=$(echo $line | tr ',' '\t' | awk '{print $1}')
  echo "No sequence available for Accession $var2, skipping this Accession" >>Sequence_retrieval_summary.txt
elif [[  "$var" =~ [\;] ]]; then
  var3=$(echo $var | tr ';' '\t' | awk '{print $1}')
  echo "$var3 Using first one given, but multiple sequences discovered. " >>Sequence_retrieval_summary.txt
#  fastq-dump '${1}'  --outdir .
else
  echo "$var" >>Sequence_retrieval_summary.txt
#  fastq-dump '${2}'  --outdir .
  fi

# remove all comments and filter out Sequence identifiers for gtype-retrieval.

done < Phenotypes_BIP_$trial_name.csv
tail -n +2 Sequence_retrieval_summary.txt >Sequence_IDs_log.txt
grep 'SRR' Sequence_IDs_log.txt | tr ',' '\t' | awk '{print $1}' >Seq_names.txt

rm Sequence_retrieval_summary.txt
