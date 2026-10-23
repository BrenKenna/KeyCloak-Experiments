#!/bin/bash

#########################################
# 
# Request Hash From Provided Endpoint
# 
#########################################

# Declare required vars
toHash=$(echo $RANDOM | md5sum -)

# Send request
date
curl -s http://localhost:8000/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"message\": \"$toHash\"}" \
 | jq .
date