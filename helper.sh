#!/bin/bash


################################################################
################################################################
##
## 1). Setup Docker Containers
##
################################################################
################################################################


# Build simple server containers
cd simpleServers
docker image build \
    -t bkenna/simple-servers:latest \
    -f nodeAlpine.Dockerfile \
    .


# Run test container
docker container run \
    --rm \
    -p 8083:80 \
    bkenna/simple-server-app \
    node index.js \
        --server serverb \
        --port 80 \
        --host 0.0.0.0

curl -s http://localhost:8083/encrypting/encrypt \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello world!"}' \
    | jq

'''
{
  "Message": "Hello world!",
  "EncryptedMessage": "1f471457a8a5d760b4b5a1dd4b025d31"
}

'''


# Start service stack
docker compose -f keycloak-server-ACL.yml up -d
docker container ls

curl -s http://localhost:8081/hashing/hashMessage \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello world!"}' \
    | jq

curl -s http://localhost:8082/encrypting/encrypt \
    -X POST \
    -H "Content-Type: application/json" \
    -d '{"message": "Hello world!"}' \
    | jq

curl -vI -s http://localhost:8093

''' 
[+] up 4/4
 ✔ Network keycloak-experiments_backend Created                                                                                      0.0s
 ✔ Container serverB                    Started                                                                                      0.4s
 ✔ Container keycloak                   Started                                                                                      0.3s
 ✔ Container serverA                    Started                                                                                      0.4s


CONTAINER ID   IMAGE                              COMMAND                  CREATED             STATUS             PORTS                                                                   NAMES
79954414cce5   quay.io/keycloak/keycloak:latest   "/opt/keycloak/bin/k…"   7 seconds ago       Up 6 seconds       8080/tcp, 8443/tcp, 9000/tcp, 0.0.0.0:8093->80/tcp, [::]:8093->80/tcp   keycloak
db31dc0784d3   bkenna/simple-server-app           "docker-entrypoint.s…"   7 seconds ago       Up 6 seconds       0.0.0.0:8082->80/tcp, [::]:8082->80/tcp                                 serverB
29163f9a9dba   bkenna/simple-server-app           "docker-entrypoint.s…"   7 seconds ago       Up 6 seconds       0.0.0.0:8081->80/tcp, [::]:8081->80/tcp                                 serverA
1f3c0ec3557b   keycloak/keycloak                  "/opt/keycloak/bin/k…"   About an hour ago   Up About an hour   8443/tcp, 0.0.0.0:8080->8080/tcp, [::]:8080->8080/tcp, 9000/tcp         eager_gagarin


--> Server A

"c0535e4be2b79ffd93291305436bf889314e4a3faec05ecffcbb7df31ad9e51a"

---> Server B

{
  "Message": "Hello world!",
  "EncryptedMessage": "87b1f6a4002efe59af9286e669592221"
}


---> Keycloak

'''