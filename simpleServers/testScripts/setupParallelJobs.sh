#!/bin/bash

# Clear previous, write out tasks
rm -fr hashing encryption
mkdir -p hashing encryption
for i in {1..1000}
    do
    echo "/usr/bin/time bash ./hashingEndpoint.sh" > hashing/$i.sh
    echo "/usr/bin/time bash ./encryptionEndpoint.sh" > encryption/$i.sh
done


# Setup exceution of hashing & encryption set
workDir=$(pwd)
ls $workDir/hashing/*sh | awk '{ print "bash '$workDir'/runTask.sh " $1 }' > hashingTasks.sh
ls $workDir/encryption/*sh | awk '{ print "bash '$workDir'/runTask.sh " $1 }' > encryptionTasks.sh