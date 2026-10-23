#!/bin/bash

######################################################################
######################################################################
# 
# Contents:
#   1). Basic project setup - Express
#   2). Building Docker image & verifying working directory
#   3). Running Express server, cURL Testing & Log Fetching
# 
######################################################################
######################################################################


##############################################
##############################################
# 
# 1). Setup
# 
##############################################
##############################################

# Initialize project
npm init

# Install dependancies
npm install -g path express log4js

# Check 
node index.js


##############################################
##############################################
# 
# 2). Build Container
# 
###############################################
###############################################


# Build container
docker build -f dockerfiles/simpleServers/nodeAlpine.Dockerfile -t simple-server-app simpleServers/
docker tag simple-server-app bkenna/simple-server-app:latest
docker push simple-server-app

# Test run container
docker run simple-server-app ls -lh


"""
total 76K
-rwxrwxrwx    1 root     root        3.3K Jul 11 18:33 helper.sh
-rwxrwxrwx    1 root     root        2.5K Jul 11 18:30 index.js
drwxrwxrwx   75 root     root        4.0K Jul 11 18:26 node_modules
-rwxrwxrwx    1 root     root       51.8K Jul 11 12:54 package-lock.json
-rwxrwxrwx    1 root     root         441 Jul 11 12:54 package.json
-rwxrwxrwx    1 root     root        1.9K Jul 11 17:37 server.js
drwxrwxrwx    5 root     root        4.0K Jul 11 18:26 supporting
"""


##############################################
##############################################
# 
# 3). Run Web Server 
# 
###############################################
###############################################


# Run app listening on port 8000
dockerContainer=$(docker run -d -p 8000:8000 simple-server-app node index.js --server 'Server-C' --port 8000)
docker logs "$dockerContainer"

docker inspect $dockerContainer | jq
docker inspect $dockerContainer | jq .[0].NetworkSettings.Networks.bridge.IPAddress

'''

--> With Server-A
2023-07-12 13:44:01.812 INFO:
Displaying Requested Server = 'Server-A'
Displaying Requested Port = '8000'

2023-07-12 13:44:01.815 INFO: Parser {
  argData: Map(3) {
    'Description' => 'Simple web server, for kubernetes tinkering with a Server-A & Server-B.',
    'Actions' => Map(0) {},
    'Global Arguments' => Map(3) { 'State' => 1, 'Server' => [Map], 'Port' => [Map] }
  }
}
2023-07-12 13:44:01.818 INFO: ServerA detected, exposing Hashing Endpoints
2023-07-12 13:44:01.818 INFO: Starting server
2023-07-12 13:44:01.822 INFO: Server configured on Port '8000', host '0.0.0.0'


--> With Server-B
2023-07-12 13:44:48.936 INFO:
Displaying Requested Server = 'Server-B'
Displaying Requested Port = '8000'

2023-07-12 13:44:48.938 INFO: Parser {
  argData: Map(3) {
    'Description' => 'Simple web server, for kubernetes tinkering with a Server-A & Server-B.',
    'Actions' => Map(0) {},
    'Global Arguments' => Map(3) { 'State' => 1, 'Server' => [Map], 'Port' => [Map] }
  }
}
2023-07-12 13:44:48.941 INFO: ServerB detected, exposing Encrypting Endpoints
2023-07-12 13:44:48.941 INFO: Starting server
2023-07-12 13:44:48.944 INFO: Server configured on Port '8000', host '0.0.0.0'


--> With the hidden ServerC
2023-07-12 13:45:49.623 INFO:
Displaying Requested Server = 'Server-C'
Displaying Requested Port = '8000'

2023-07-12 13:45:49.625 INFO: Parser {
  argData: Map(3) {
    'Description' => 'Simple web server, for kubernetes tinkering with a Server-A & Server-B.',
    'Actions' => Map(0) {},
    'Global Arguments' => Map(3) { 'State' => 1, 'Server' => [Map], 'Port' => [Map] }
  }
}
2023-07-12 13:45:49.628 WARN: Unable to detect which server to run, exposing hashing & encrypted endpoints
2023-07-12 13:45:49.628 INFO: Starting server
2023-07-12 13:45:49.631 INFO: Server configured on Port '8000', host '0.0.0.0'

'''


# Fetch welcom message
curl http://localhost:8000/ | jq

'''
{
  "Hello": "World!!!"
}
'''

# Fetch hash of message
curl http://localhost:8000/hashing/hashMessage \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
 | jq

curl http://localhost:8000/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
 | jq

'''

--> Endpoint-1
c931496a5ced8b863bf82212a7029436c35a24a24c946a9c67142737ca15260b


--> Endpoint-2

{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "a9ee3d887679ed4cf4b299e711731c20e20f60b93320ff0b3a5edad8e4ca46e2",
  "Salt": "91f28ed0-61f0-4338-a4bf-30d5a4f21c3c"
}
'''


# Encrypt a message
curl http://localhost:8000/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
 | jq

'''
{
  "Message": "xdfrtyu7i8opl;lkj",
  "EncryptedMessage": "bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a"
}
'''


# Decrypt a message
curl http://localhost:8000/encrypting/decrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a"}' \
 | jq

'''
{
  "Message": "bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a",
  "DecryptedMesssage": "xdfrtyu7i8opl;lkj"
}
'''


# Display server logs following tests
docker logs "$dockerContainer"

'''
2023-07-12 10:45:42 INFO: A new test request has come in

2023-07-12 10:46:31 INFO: A new hashing request has come in

2023-07-12 10:46:31 INFO: { message: 'xdfrtyu7i8opl;lkj' }

2023-07-12 10:46:31 INFO: c931496a5ced8b863bf82212a7029436c35a24a24c946a9c67142737ca15260b

2023-07-12 10:47:19 INFO: A new hashing request has come in

2023-07-12 10:47:19 INFO: { message: 'xdfrtyu7i8opl;lkj' }

2023-07-12 10:47:19 INFO: {
  Message: 'xdfrtyu7i8opl;lkj',
  Hash: 'a9ee3d887679ed4cf4b299e711731c20e20f60b93320ff0b3a5edad8e4ca46e2',
  Salt: '91f28ed0-61f0-4338-a4bf-30d5a4f21c3c'
}

2023-07-12 10:47:46 INFO: A new encryption request has come in

2023-07-12 10:47:46 INFO: { message: 'xdfrtyu7i8opl;lkj' }

2023-07-12 10:47:46 INFO: {
  Message: 'xdfrtyu7i8opl;lkj',
  EncryptedMessage: 'bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a'
}

2023-07-12 10:48:20 INFO: A new decryption request has come in

2023-07-12 10:48:20 INFO: {
  message: 'bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a'
}

2023-07-12 10:48:20 INFO: {
  Message: 'bc44989fb3a7c335152720c5be12c802ccd733769456dc2581e84b5159452c5a',
  DecryptedMesssage: 'xdfrtyu7i8opl;lkj'
}
'''


##############################################
##############################################
# 
# 4). See how parallel requests get handled
# 
###############################################
###############################################


########################################
########################################
#
# 4-a). Hashing Server Tests
# 
########################################
########################################


# Set up task scripts, N = 1000
cd simpleServers/testScripts
bash setupParallelJobs.sh


# Run hashing tasks in parallel
rm -f hashingTasks.log
nohup bash runBatch.sh hashingTasks.sh 3 &> hashingTasks-3para.log &
nohup bash runBatch.sh hashingTasks.sh 15 &> hashingTasks-15para.log &
nohup bash runBatch.sh hashingTasks.sh 30 &> hashingTasks-30para.log &
nohup bash runBatch.sh hashingTasks.sh 90 &> hashingTasks-90para.log &
nohup bash runBatch.sh hashingTasks.sh 120 &> hashingTasks-120para.log &
nohup bash runBatch.sh hashingTasks.sh 180 &> hashingTasks-180para.log &
nohup bash runBatch.sh hashingTasks.sh 250 &> hashingTasks-250para.log &
nohup bash runBatch.sh hashingTasks.sh 500 &> hashingTasks-500para.log &
nohup bash runBatch.sh hashingTasks.sh 1000 &> hashingTasks-1000para.log &
head hashingTasks.log && tail hashingTasks.log

'''

--> While curious how different results will look handling requests from N different clients.
--> There were no obvious (task & server logs), can handle all 1k parallel requests.
--> But the processing of all 1000, usually ~5ms faster with higher resource util.

- 1k Parallel Tasks
0.01user 0.00system 0:00.03elapsed 59%CPU (0avgtext+0avgdata 11052maxresident)k
0inputs+0outputs (0major+1493minor)pagefaults 0swaps
        Command being timed: "parallel -j 1000"
        User time (seconds): 36.36
        System time (seconds): 74.82
        Percent of CPU this job got: 740%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.00

- 500 Parallel Tasks
0.01user 0.01system 0:00.04elapsed 55%CPU (0avgtext+0avgdata 11052maxresident)k
0inputs+0outputs (0major+1500minor)pagefaults 0swaps
        Command being timed: "parallel -j 500"
        User time (seconds): 36.50
        System time (seconds): 72.98
        Percent of CPU this job got: 740%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.79

- 250 Parallel Tasks
0.00user 0.01system 0:00.03elapsed 54%CPU (0avgtext+0avgdata 11076maxresident)k
0inputs+0outputs (0major+1494minor)pagefaults 0swaps
        Command being timed: "parallel -j 250"
        User time (seconds): 35.56
        System time (seconds): 79.14
        Percent of CPU this job got: 775%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.78

- 180 Parallel Tasks
0.02user 0.00system 0:00.04elapsed 54%CPU (0avgtext+0avgdata 10856maxresident)k
0inputs+0outputs (1major+1513minor)pagefaults 0swaps
        Command being timed: "parallel -j 180"
        User time (seconds): 35.18
        System time (seconds): 76.06
        Percent of CPU this job got: 771%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.42

- 120 Parallel Tasks
0.01user 0.01system 0:00.05elapsed 50%CPU (0avgtext+0avgdata 10888maxresident)k
0inputs+0outputs (1major+1510minor)pagefaults 0swaps
        Command being timed: "parallel -j 120"
        User time (seconds): 36.52
        System time (seconds): 79.44
        Percent of CPU this job got: 772%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:15.01


- 90 Parallel Tasks
0.01user 0.00system 0:00.04elapsed 55%CPU (0avgtext+0avgdata 11116maxresident)k
0inputs+0outputs (1major+1509minor)pagefaults 0swaps
        Command being timed: "parallel -j 90"
        User time (seconds): 33.97
        System time (seconds): 72.94
        Percent of CPU this job got: 776%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.77


- 30 Parallel Tasks
0.00user 0.01system 0:00.03elapsed 58%CPU (0avgtext+0avgdata 10824maxresident)k
0inputs+0outputs (0major+1506minor)pagefaults 0swaps
        Command being timed: "parallel -j 30"
        User time (seconds): 34.96
        System time (seconds): 70.42
        Percent of CPU this job got: 771%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.65


- 15 Parallel Tasks
0.02user 0.00system 0:00.03elapsed 59%CPU (0avgtext+0avgdata 10916maxresident)k
0inputs+0outputs (0major+1499minor)pagefaults 0swaps
        Command being timed: "parallel -j 15"
        User time (seconds): 34.11
        System time (seconds): 49.15
        Percent of CPU this job got: 564%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.75


- 3 Parallel Tasks
0.01user 0.00system 0:00.02elapsed 54%CPU (0avgtext+0avgdata 11164maxresident)k
0inputs+0outputs (0major+1502minor)pagefaults 0swaps
        Command being timed: "parallel -j 3"
        User time (seconds): 23.79
        System time (seconds): 8.29
        Percent of CPU this job got: 166%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:19.31

'''

# Sanity check responses
grep -ic "salt" hashingTasks*log

''' --> All should be 1k

hashingTasks-1000para.log:1000
hashingTasks-120para.log:1000
hashingTasks-15para.log:1000
hashingTasks-180para.log:1000
hashingTasks-250para.log:1000
hashingTasks-30para.log:1000
hashingTasks-3para.log:1000
hashingTasks-500para.log:1000
hashingTasks-90para.log:1000
'''


########################################
########################################
#
# 4-b). Encryption Tests
#
# - Decryption not done, as it needs
#     an encrypted message
# 
########################################
########################################


# Run encryption tests in parallel
rm -f encryptionTasks.log
nohup bash runBatch.sh encryptionTasks.sh 3 &> encryptionTasks-3para.log &
nohup bash runBatch.sh encryptionTasks.sh 15 &> encryptionTasks-15para.log &
nohup bash runBatch.sh encryptionTasks.sh 30 &> encryptionTasks-30para.log &
nohup bash runBatch.sh encryptionTasks.sh 90 &> encryptionTasks-90para.log &
nohup bash runBatch.sh encryptionTasks.sh 120 &> encryptionTasks-120para.log &
nohup bash runBatch.sh encryptionTasks.sh 180 &> encryptionTasks-180para.log &
nohup bash runBatch.sh encryptionTasks.sh 250 &> encryptionTasks-250para.log &
nohup bash runBatch.sh encryptionTasks.sh 500 &> encryptionTasks-500para.log &
nohup bash runBatch.sh encryptionTasks.sh 1000 &> encryptionTasks-1000para.log &

head encryptionTasks.log && tail encryptionTasks.log

'''

--> Results are about the same
--> Somewhat surprised given that messages are encrypted, but similar speed.
      => Given that the program used for running parallel tasks, would be optimized.
      => Would still be curious if results hold-up for requests from N separate nodes instead.
           => More chaotic, if so would not see benefit of hashing salted passwords over encrypting salted.


- 1k Parallel Tasks
0.00user 0.01system 0:00.04elapsed 55%CPU (0avgtext+0avgdata 10848maxresident)k
0inputs+0outputs (0major+1498minor)pagefaults 0swaps
        Command being timed: "parallel -j 1000"
        User time (seconds): 35.98
        System time (seconds): 75.47
        Percent of CPU this job got: 776%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.36


- 500 Parallel Tasks
0.01user 0.00system 0:00.03elapsed 56%CPU (0avgtext+0avgdata 10852maxresident)k
0inputs+0outputs (0major+1509minor)pagefaults 0swaps
        Command being timed: "parallel -j 500"
        User time (seconds): 34.43
        System time (seconds): 79.13
        Percent of CPU this job got: 771%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.72


- 250 Parallel Tasks
0.01user 0.00system 0:00.04elapsed 54%CPU (0avgtext+0avgdata 10952maxresident)k
0inputs+0outputs (1major+1505minor)pagefaults 0swaps
        Command being timed: "parallel -j 250"
        User time (seconds): 35.66
        System time (seconds): 75.42
        Percent of CPU this job got: 769%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.44

- 180 Parallel Tasks
0.02user 0.00system 0:00.04elapsed 62%CPU (0avgtext+0avgdata 10952maxresident)k
0inputs+0outputs (0major+1506minor)pagefaults 0swaps
        Command being timed: "parallel -j 180"
        User time (seconds): 34.97
        System time (seconds): 76.18
        Percent of CPU this job got: 784%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.17


- 120 Parallel Tasks
0.01user 0.01system 0:00.04elapsed 53%CPU (0avgtext+0avgdata 10836maxresident)k
0inputs+0outputs (1major+1510minor)pagefaults 0swaps
        Command being timed: "parallel -j 120"
        User time (seconds): 36.42
        System time (seconds): 81.85
        Percent of CPU this job got: 788%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.99


- 90 Parallel Tasks
0.00user 0.01system 0:00.04elapsed 53%CPU (0avgtext+0avgdata 11164maxresident)k
0inputs+0outputs (0major+1499minor)pagefaults 0swaps
        Command being timed: "parallel -j 90"
        User time (seconds): 35.93
        System time (seconds): 70.69
        Percent of CPU this job got: 762%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.99


- 30 Parallel Tasks
0.02user 0.00system 0:00.04elapsed 55%CPU (0avgtext+0avgdata 10888maxresident)k
0inputs+0outputs (0major+1511minor)pagefaults 0swaps
        Command being timed: "parallel -j 30"
        User time (seconds): 36.07
        System time (seconds): 70.24
        Percent of CPU this job got: 776%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:13.68


- 15 Parallel Tasks
0.01user 0.00system 0:00.03elapsed 62%CPU (0avgtext+0avgdata 10776maxresident)k
0inputs+0outputs (0major+1508minor)pagefaults 0swaps
        Command being timed: "parallel -j 15"
        User time (seconds): 36.28
        System time (seconds): 60.36
        Percent of CPU this job got: 668%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:14.46


- 3 Parallel Tasks
0.01user 0.00system 0:00.02elapsed 56%CPU (0avgtext+0avgdata 11072maxresident)k
0inputs+0outputs (0major+1493minor)pagefaults 0swaps
        Command being timed: "parallel -j 3"
        User time (seconds): 23.58
        System time (seconds): 8.39
        Percent of CPU this job got: 163%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:19.50
'''


# Sanity check responses
grep -ic "encryptedm" encryptionTasks*log

''' --> All should be 1k

encryptionTasks-1000para.log:1000
encryptionTasks-120para.log:1000
encryptionTasks-15para.log:1000
encryptionTasks-180para.log:1000
encryptionTasks-250para.log:1000
encryptionTasks-30para.log:1000
encryptionTasks-3para.log:1000
encryptionTasks-500para.log:1000
encryptionTasks-90para.log:1000
'''