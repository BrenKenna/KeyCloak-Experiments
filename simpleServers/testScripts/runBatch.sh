#!/bin/bash

# Run task set in batches of N
batchSet=$1
nTasks=$2
now=$(date)
echo -e "\nRunning Batch Set:\t$batchSet"
echo -e "Parallel Tasks:\t\t$nTasks"
echo -e "Start time:\t\t$now"
/usr/bin/time -v parallel -j $nTasks < $batchSet
now=$(date)
echo -e "\n\nEnd time:\t$now"