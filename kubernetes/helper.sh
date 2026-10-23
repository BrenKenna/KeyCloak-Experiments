#!/bin/bash

######################################################################
######################################################################
# 
# Contents:
#      i). Run serverA in a Pod.
#     ii). Deploy as Service.
#    iii). Deploy all three bundled in one service.
#     iv). Deploy as seperate services
#
# Bastion host could be interesting:
#  https://hub.docker.com/r/linuxserver/openssh-server
# 
######################################################################
######################################################################


######################################
######################################
#
# 1). Run a Pod
#
######################################
######################################


# Deploy simpleServerA pod
kubectl apply -f kubernetes-deployment\simpleServers\simpleServerA-Pod.yaml
kubectl get pod simple-server-a -o wide
kubectl logs simple-server-a
kubectl describe pod simple-server-a
kubectl delete pod simple-server-a


'''

--> Get
NAME              READY   STATUS    RESTARTS      AGE   IP          NODE             NOMINATED NODE   READINESS GATES
simple-server-a   1/1     Running   1 (42m ago)   70m   10.1.0.52   docker-desktop   <none>           <none>

--> Logs
2023-07-13 22:40:36.285 INFO: ServerA detected, exposing Hashing Endpoints
2023-07-13 22:40:36.285 INFO: Starting server
2023-07-13 22:40:36.290 INFO: Server configured on Port '8000', host '0.0.0.0'

--> Describe
Name:         simple-server-a
Namespace:    default
Status:       Running
IP:           10.1.0.52
Containers:
  simple-server-a:
    Container ID:  docker://59a1a8f300f460bddf8aafee226e2151f4dc9069faa05855a75db5fcffe2c4f9
    Image:         bkenna/simple-server-app
    Image ID:      docker-pullable://bkenna/simple-server-app@sha256:53b3e1b4fd09d95326b03c481e4098d7ca7f9a0505ff67aeaf08c361d6d5851c
    Port:          8000/TCP
    Host Port:     8000/TCP
    Command:
      /usr/local/bin/node
    Args:
      index.js
      --server
      Server-A
      --port
      8000
    State:          Running
      Started:      Thu, 13 Jul 2023 23:40:35 +0100
'''


######################################
######################################
#
# 2). Deploy a Service
#
######################################
######################################


# Run simpleServerA deployment
kubectl apply -f kubernetes-deployment\simpleServers\simpleServerA-deployment.yaml
kubectl get pods simple-server-a-8667d8d9cb-kn7gq -o wide
kubectl logs simple-server-a--8667d8d9cb-kn7gq

'''
deployment.apps/simple-server-a created

--> Noteable fields sides first few
{
    "spec": {
        "volumes": [],
        "dnsPolicy": "ClusterFirst",
        "schedulerName": "default-scheduler",
        "securityContext": {},
        "serviceAccount": "default",
        "serviceAccountName": "default",
        "nodeName": "dockerDesktop"
    }
    "phase": "Running"
}


--> Logs

2023-07-13 23:10:56.813 INFO: ServerA detected, exposing Hashing Endpoints
2023-07-13 23:10:56.813 INFO: Starting server
2023-07-13 23:10:56.818 INFO: Server configured on Port '8000', host '0.0.0.0'

'''


# Inspect deployment
kubectl get deployment -o wide
kubectl get replicaset -o wide


'''

--> Deployment
NAME              READY   UP-TO-DATE   AVAILABLE   AGE    CONTAINERS        IMAGES                     SELECTOR
simple-server-a   1/1     1            1           9m6s   simple-server-a   bkenna/simple-server-app   app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server-a


--> Replicaset

NAME                         DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                     SELECTOR
simple-server-a-8667d8d9cb   1         1         1       9m32s   simple-server-a   bkenna/simple-server-app   app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server-a,pod-template-hash=8667d8d9cb
'''


# Run the simpleServerA service
kubectl apply -f kubernetes-deployment\simpleServers\simpleServerA-service.yaml
kubectl expose deployment simple-server-a --type=NodePort --name=simple-server-a
kubectl get service simple-server-a -o wide
kubectl describe services simple-server-a

'''
service/simple-server-a created

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE     SELECTOR
simple-server-a   ClusterIP   10.98.132.115   <none>        8000/TCP   3m36s   app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server-a

NAME              TYPE       CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE   SELECTOR
simple-server-a   NodePort   10.104.69.229   <none>        8000:30375/TCP   39s   app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server-a


Name:                     simple-server-a
Namespace:                default
Labels:                   app.kubernetes.io/component=yolo
                          app.kubernetes.io/name=simple-server-a
Annotations:              <none>
Selector:                 app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server-a
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.104.69.229
IPs:                      10.104.69.229
LoadBalancer Ingress:     localhost
Port:                     <unset>  8000/TCP
TargetPort:               8000/TCP
NodePort:                 <unset>  30375/TCP
Endpoints:                10.1.0.55:8000
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
'''

# Post a hashing with salt request to exposed endpoint
curl http://localhost:30375/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
 | jq .

kubectl logs service/simple-server-a

'''

--> Request results

{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "98e9a19c0cf1b3ce17543240caae22f553441cb2af94ef241c0ff357d647f522",
  "Salt": "a79a9c5d-522a-4d1a-8eda-97bed90a3bdb"
}


--> Server logs

2023-07-13 23:10:56.807 INFO:
Displaying Requested Server = 'Server-A'
Displaying Requested Port = '8000'

2023-07-13 23:10:56.810 INFO: Parser {
  argData: Map(3) {
    'Description' => 'Simple web server, for kubernetes tinkering with a Server-A & Server-B.',
    'Actions' => Map(0) {},
    'Global Arguments' => Map(3) { 'State' => 1, 'Server' => [Map], 'Port' => [Map] }
  }
}
2023-07-13 23:10:56.813 INFO: ServerA detected, exposing Hashing Endpoints
2023-07-13 23:10:56.813 INFO: Starting server
2023-07-13 23:10:56.818 INFO: Server configured on Port '8000', host '0.0.0.0'
2023-07-13 23:58:51.709 INFO: A new test request has come in
2023-07-14 00:00:29.771 INFO: A new hashing request has come in
2023-07-14 00:00:29.772 INFO: { message: 'xdfrtyu7i8opl;lkj' }
2023-07-14 00:00:29.780 INFO: {
  Message: 'xdfrtyu7i8opl;lkj',
  Hash: '98e9a19c0cf1b3ce17543240caae22f553441cb2af94ef241c0ff357d647f522',
  Salt: 'a79a9c5d-522a-4d1a-8eda-97bed90a3bdb'
}

'''


######################################
######################################
#
# 3). Deploy Bundled Service
#
######################################
######################################


# See what happens
kubectl apply -f kubernetes-deployment\simpleServerssimpleServer-deployment.yaml
kubectl expose deployment simple-server --type=NodePort --name=simple-server
kubectl describe services simple-server

'''
Name:                     simple-server
Namespace:                default
Labels:                   app.kubernetes.io/component=yolo
                          app.kubernetes.io/name=simple-server
Annotations:              <none>
Selector:                 app.kubernetes.io/component=yolo,app.kubernetes.io/name=simple-server
Type:                     NodePort
IP Family Policy:         SingleStack
IP Families:              IPv4
IP:                       10.110.145.96
IPs:                      10.110.145.96
LoadBalancer Ingress:     localhost
Port:                     port-1  8000/TCP
TargetPort:               8000/TCP
NodePort:                 port-1  30628/TCP
Endpoints:                10.1.0.69:8000
Port:                     port-2  8001/TCP
TargetPort:               8001/TCP
NodePort:                 port-2  30719/TCP
Endpoints:                10.1.0.69:8001
Port:                     port-3  8002/TCP
TargetPort:               8002/TCP
NodePort:                 port-3  30228/TCP
Endpoints:                10.1.0.69:8002
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>

'''


# Test hashing requests: ServerA
curl --silent http://localhost:30628/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

'''
{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "55de1e35d8b49e9990726d27187b4153bfee4558a39df51efa800b46b42a9520",
  "Salt": "f96f80c7-e35b-4af7-84bc-778022ea5513"
}
'''


# Test encryption: ServerB
curl --silent http://localhost:30719/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

'''
{
  "Message": "xdfrtyu7i8opl;lkj",
  "EncryptedMessage": "dc77e8d78882353b4cf05adfb054979561a308841cb00cbf199433fc787c3c76"
}
'''

# Test both hashing & encryption: ServerC
curl --silent http://localhost:30228/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

curl --silent http://localhost:30228/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .


'''

{
  "Message": "xdfrtyu7i8opl;lkj",
  "EncryptedMessage": "2143560b8cad53ff6ce4d5c40ac284577efa708f23f35de2b568b9aa8938c602"
}


{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "e4b68580f34c7e64347e71dacf89c7ea41818ad2e0aa28b151a3164bdc45c4eb",
  "Salt": "b2a3136c-0d52-4877-830b-022e321a6b23"
}

'''


######################################
######################################
#
# 4). Deploy Separate Services
#
######################################
######################################


# Deploy each service
kubectl apply -f kubernetes-deployment\micro-services\simpleServer-Deployment.yaml

'''
deployment.apps/simple-server-a created
deployment.apps/simple-server-b created
deployment.apps/simple-server-c created
'''

# Expose each deployment
kubectl expose deployment simple-server-a --type=NodePort --name=simple-server-a
kubectl expose deployment simple-server-b --type=NodePort --name=simple-server-b
kubectl expose deployment simple-server-c --type=NodePort --name=simple-server-c

kubectl describe services simple-server-a

'''
service/simple-server-a exposed   --> 31489/TCP
service/simple-server-b exposed   --> 30558/TCP
service/simple-server-c exposed   --> 31496/TCP
'''


# Test server-a
curl --silent http://localhost:31489/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .


'''
{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "077eb54554b06a4ea3ccbb84eab53b059dcae74ca098065aa8ca67e6bf712219",
  "Salt": "59dc7b1c-a2ca-4dc0-8520-64273f91f2f3"
}
'''

# Test server-b
curl --silent http://localhost:31815/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

curl --silent http://localhost:30558/encrypting/decrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "664f77d641222e1064d7e96d6301679c0baeacdb8774bc2be3a043c12f355e99"}' \
| jq .

'''

{
  "Message": "xdfrtyu7i8opl;lkj",
  "EncryptedMessage": "664f77d641222e1064d7e96d6301679c0baeacdb8774bc2be3a043c12f355e99"
}


{
  "Message": "664f77d641222e1064d7e96d6301679c0baeacdb8774bc2be3a043c12f355e99",
  "DecryptedMesssage": "xdfrtyu7i8opl;lkj"
}

'''

# Test server-c
curl --silent http://localhost:31496/encrypting/encrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

curl --silent http://localhost:31496/encrypting/decrypt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "664f77d641222e1064d7e96d6301679c0baeacdb8774bc2be3a043c12f355e99"}' \
| jq .

curl --silent http://localhost:31496/hashing/hashMessageWithSalt \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"message": "xdfrtyu7i8opl;lkj"}' \
| jq .

'''

{
  "Message": "xdfrtyu7i8opl;lkj",
  "EncryptedMessage": "cee0f4bce53cf32833aa011a741e6b6c17d6026a4acbe940134af9410efacccd"
}

{
  "Message": "cee0f4bce53cf32833aa011a741e6b6c17d6026a4acbe940134af9410efacccd",
  "DecryptedMesssage": "xdfrtyu7i8opl;lkj"
}

{
  "Message": "xdfrtyu7i8opl;lkj",
  "Hash": "7e5c633a78d4e34c65736cd31e67240d429ed36a305b6f7575386aae380d2730",
  "Salt": "6d8738f6-bb96-43d5-8990-8436c2cc9756"
}

'''


# Kill services and deployments
kubectl delete service/simple-server-a service/simple-server-b service/simple-server-c
kubectl delete deployment/simple-server-a deployment/simple-server-b deployment/simple-server-c



##########################################
##########################################
# 
# 5). Deploy TaskManager Service
# 
##########################################
##########################################


# Deploy & Expose named service
kubectl apply -f kubernetes-deployment\task-manager\taskManager-Deployment.yml
kubectl expose deployment task-manager --type=NodePort --name=task-manager

kubectl describe service/task-manager

'''
NodePort:                 <unset>  32030/TCP
'''


# Should be nothing, because initial server port = 3000
curl -Iv http://localhost:32030/tasks

'''
*   Trying ::1:32030...
* Connected to localhost (::1) port 32030 (#0)
> HEAD /tasks HTTP/1.1
> Host: localhost:32030
> User-Agent: curl/7.71.1
> Accept: */*
>
* Recv failure: Connection was aborted
* Closing connection 0
curl: (56) Recv failure: Connection was aborted

'''


# Update deployment image, following change to port 80
docker build -f dockerfiles/task-manager/nodeApline.Dockerfile -t task-manager-app task-manager
docker tag task-manager-app bkenna/task-manager-app:latest
docker push task-manager-app


# Update & apply deployment changes
kubectl apply -f kubernetes-deployment\task-manager\taskManager-Deployment.yml


'''

---> Before

NAME                           READY   STATUS    RESTARTS   AGE
task-manager-5fbbb49f8-hc6kl   1/1     Running   0          9m43s
task-manager-5fbbb49f8-swn44   1/1     Running   0          9m43s


---> During

NAME                           READY   STATUS        RESTARTS   AGE
task-manager-5fbbb49f8-hc6kl   1/1     Terminating   0          10m
task-manager-5fbbb49f8-swn44   1/1     Terminating   0          10m
task-manager-79dc6b8fb-q9rxl   1/1     Running       0          19s
task-manager-79dc6b8fb-r4qb7   1/1     Running       0          24s

---> After

NAME                           READY   STATUS    RESTARTS   AGE
task-manager-79dc6b8fb-q9rxl   1/1     Running   0          39s
task-manager-79dc6b8fb-r4qb7   1/1     Running   0          44s

'''


# Query endpoint following, deployment update
curl --silent http://localhost:32030
curl --silent http://localhost:32030/tasks
curl --silent http://localhost:32030/task \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"title": "donald duck", "description": "remeber what donald duck is"}' \
| jq .
curl --silent http://localhost:32030/tasks

'''

{"hello":"world"}
[]
{
  "title": "donald duck",
  "description": "remeber what donald duck is"
}

----> Consistency is key :c

[
  {
    "title": "donald duck",
    "description": "remeber what donald duck is"
  },
  {
    "title": "donald duck",
    "description": "remeber what donald duck is"
  }
]
[
  {
    "title": "daffy duck",
    "description": "remeber what this other duck is"
  }
]
'''


#############################################
#############################################
# 
# - Helm Chart for Task Manager
# 
#############################################
#############################################

# Create
helm create task-manager-helm

# Move yml after clearing default
mv *yml task-manager-helm/templates/

# Build dependencies & install into cluster
helm dependency build kubernetes-deployment/task-manager-helm/
helm uninstall task-manager-app
helm install \
  task-manager-app \
  kubernetes-deployment/task-manager-helm/ \
  --set redis.auth.enabled=true,redis.auth.password=D0IvK3-K0iV6!