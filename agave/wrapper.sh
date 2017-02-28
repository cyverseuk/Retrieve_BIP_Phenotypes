#!/bin/bash


trial_name="${param_1}"
api_key="${param_2}"


cp Phenotypes_Condor_submit.htc condorsubmit.htc
#echo transfer_input_files = ${input_1} >> condorsubmit.htc
echo arguments = ${param_1}  >> condorsubmit.htc
echo arguments = ${param_2} >> condorsubmit.htc
echo transfer_output_files = Seq_names.txt, Phenotypes_BIP_${param_1}.csv
#H5COMMA=`echo ${h5} | sed -e 's/ /,/g'`
#echo transfer_input_files = ${adapters},$H5COMMA >> sratools_submit.htc
echo queue >> condorsubmit.htc

jobid=`condor_submit condorsubmit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

exit 0
