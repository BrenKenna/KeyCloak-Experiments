#!/bin/bash

###############################################################
###############################################################
#
# Create Secret Directly With Kubectl
#
#  => Since a computer has to run its deployment
# 
###############################################################
###############################################################

# Fake userID and password
echo -e "
userID='3f0c7256-adcf-4f0e-9986-586a9e338999'
pass='|rx/vL}_(F@c>@6K'
" > .secret.txt

kubectl create secret generic simple-server-secret \
    --from-file='userID=.secret.txt' \
    --from-file='pass=.secret.txt'


# Checkout
kubectl describe secrets
kubectl get secret simple-server-secret

'''
Name:         simple-server-secret
Namespace:    default
Labels:       <none>
Annotations:  <none>

Type:  Opaque

Data
====
pass:    72 bytes
userID:  72 bytes

NAME                   TYPE     DATA   AGE
simple-server-secret   Opaque   2      26s

'''


##########################
##########################
#
# Deploy
#
##########################
##########################


# Deploy all the same
kubectl apply -f simpleServer-Deployment.yaml
kubectl apply -f simpleServer-Service.yaml
kubectl describe pods/simple-server-a-964d8-6pznf

kubectl exec \
    -it pods/simple-server-a-964d8-6pznf \
    -- /bin/sh
df -h
ls /etc/secret-volume
head /etc/secret-volume/*


'''
tmpfs                   128.0M      8.0K    128.0M   0% /etc/secret-volume
pass    userID
==> /etc/secret-volume/pass <==

userID='3f0c7256-adcf-4f0e-9986-586a9e338999'
pass='|rx/vL}_(F@c>@6K'


==> /etc/secret-volume/userID <==

userID='3f0c7256-adcf-4f0e-9986-586a9e338999'
pass='|rx/vL}_(F@c>@6K'


Controlled By:  ReplicaSet/simple-server-a-964d8
Containers:
  simple-server-a:
    Container ID:  docker://8ff9ec169026e37c0a371f14c8b640f4ae052da5a47ada9d910b4357f1c5c1a6
    Image:         bkenna/simple-server-app
    State:          Running
      Started:      Thu, 28 Dec 2023 13:35:27 +0000
    Mounts:
      /etc/secret-volume from secret-volume (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-xqjsk (ro)
Volumes:
  secret-volume:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  simple-server-secret
  Normal  Created    37s    kubelet            Created container simple-server-a
  Normal  Started    37s    kubelet            Started container simple-server-a


deployment.apps/simple-server-a created
deployment.apps/simple-server-b created
deployment.apps/simple-server-c created

service/simple-server-a created
service/simple-server-b created
service/simple-server-c created

'''


# Update server-B to use env var
kubectl exec \
    -it pods/simple-server-b-76dbf47cfd-r9z4l \
    -- /bin/sh

printenv

'''
SECRET_DATA=
userID='3f0c7256-adcf-4f0e-9986-586a9e338999'
pass='|rx/vL}_(F@c>@6K'
'''