#!/bin/bash

#############################################
# 
# Request Encrypion From Provided Endpoint
# 
#############################################

# Declare required vars
toEncrypt=$(echo $RANDOM | md5sum -)

# Send request
date
curl -s http://localhost:8000/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"$toEncrypt\"}" \
 | jq .
date