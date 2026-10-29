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


################################################################
################################################################
##
## 2). Build App
##
################################################################
################################################################

# v> supports node-sea
nvm install 26
nvm use 26
nvm alias default 26


# Install build tools
npm install body-parser
npm install --save-dev esbuild


# Build with dependencies
./node_modules/.bin/esbuild index.js \
  --bundle \
  --platform=node \
  --format=cjs \
  --packages=bundle \
  --outfile=dist/simpleServers.cjs

node --build-sea sea-config.json


'''

  dist\simpleServers.cjs  2.2mb


Generated single executable /home/bren/.nvm/versions/node/v26.13.0/bin/node + sea-config.json -> dist/simple-servers

'''




################################################################
################################################################
##
## 3). Configure Server
##
################################################################
################################################################


# Acquire bearer token
export KC_USER="admin"
export KC_PASS="password"
export KC_URL="http://localhost:8093"
export KC_TOKEN=$(
    curl -s \
        -X POST "$KC_URL/realms/master/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=password" \
        -d "client_id=admin-cli" \
        -d "username=$KC_USER" \
        -d "password=$KC_PASS" | \
    jq -r '.access_token'
)


for field in $( echo $KC_TOKEN | sed 's/\./ /g' )
do
    echo -e "\n\nDecoding JWT field:\t$field\n"
    echo "$field" | tr '_-' '/+' | base64 -d | jq
done



'''

{
  "access_token": "eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJUZHMzOTRnVkIzbDd2SXp4ekVMQjh3Qzc4LS1vMW9TdmFvaTMxc0RUZTJ3In0.eyJleHAiOjE3OTMyNzA5MTQsImlhdCI6MTc5MzI3MDg1NCwianRpIjoib25sdHJvOjFkMDM2YjI1LTliZDAtZjIxNS1jNzNhLTAxYzIyYjc2NjM3OSIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA5My9yZWFsbXMvbWFzdGVyIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYWRtaW4tY2xpIiwic2lkIjoiRnpMekJlQkxILURxeUdBV3F4YWhfaWUxIiwic2NvcGUiOiJwcm9maWxlIGVtYWlsIn0.F9qb56h7IMsGTVso2R2Tdn0moM9ynC3MNfXFHLEyH0OJZHzVJg4iOfGCrb8h6t0b9ZMPzTefPKIaapsSuemC6JkTMC-WS7pURbwdwh1aBSfgNe-Y-wHRlLseC9XbhOflGjPRejqAxUiZNCm1ospK7ZRjyLogrK7cBj346GmsWQTP27loyqN3Q-ZJmitgy8G_ej0ofJG-ojfnXPGdlsq3fBAS9uEcOFmO1pYNejBXcwdvZOsYOpZfmpgVH4_sDqH7f5U8dWcYfAVJGM-TssMo_EW-K1EI5L7XG2_eTRQnaYZ3-pkqhsv5DJCnN-dcKudIVf2bfG1akNjMaBubm9nOBA",
  "expires_in": 60,
  "refresh_expires_in": 1800,
  "refresh_token": "eyJhbGciOiJIUzUxMiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI3MTRkNjljOS1mZWY4LTQ2NTgtOTE5ZC1hMWViNmY4M2EzZTQifQ.eyJleHAiOjE3OTMyNzI2NTQsImlhdCI6MTc5MzI3MDg1NCwianRpIjoiYjQyMWFkODctYmU0ZS00ZDYzLTcwYzctNDBhMjEzNWEzOGVlIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDkzL3JlYWxtcy9tYXN0ZXIiLCJhdWQiOiJodHRwOi8vbG9jYWxob3N0OjgwOTMvcmVhbG1zL21hc3RlciIsInR5cCI6IlJlZnJlc2giLCJhenAiOiJhZG1pbi1jbGkiLCJzaWQiOiJGekx6QmVCTEgtRHF5R0FXcXhhaF9pZTEiLCJzY29wZSI6InByb2ZpbGUgYWNyIHdlYi1vcmlnaW5zIHJvbGVzIGJhc2ljIGVtYWlsIiwicHJvdiI6ImRlZmF1bHQifQ.VuPmWfP_aa2vc1N7pjct_RxjdT9JjpjN4ke8SMKzQ1PlTWimTWODaWiKIX6vKB_SGPZ4xl90xrghVmbeuWZ0iQ",
  "token_type": "Bearer",
  "not-before-policy": 0,
  "session_state": "FzLzBeBLH-DqyGAWqxah_ie1",
  "scope": "profile email"
}


---> Decode JWT

1). Header
Decoding JWT field:     eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJUZHMzOTRnVkIzbDd2SXp4ekVMQjh3Qzc4LS1vMW9TdmFvaTMxc0RUZTJ3In0

{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "Tds394gVB3l7vIzxzELB8wC78--o1oSvaoi31sDTe2w"
}


2). Decoding JWT field:     eyJleHAiOjE3OTMyNzEyODQsImlhdCI6MTc5MzI3MTIyNCwianRpIjoib25sdHJvOjU1NzM0MzYwLTVlNzgtZWFmNi1hZGI4LTA0ZmU5N2EzMzE2MiIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA5My9yZWFsbXMvbWFzdGVyIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoiYWRtaW4tY2xpIiwic2lkIjoiUFhQODR1TWxUZF9RdE1KZVA5NVRCSXFTIiwic2NvcGUiOiJwcm9maWxlIGVtYWlsIn0

{
  "exp": 1793271284,
  "iat": 1793271224,
  "jti": "onltro:55734360-5e78-eaf6-adb8-04fe97a33162",
  "iss": "http://localhost:8093/realms/master",
  "typ": "Bearer",
  "azp": "admin-cli",
  "sid": "PXP84uMlTd_QtMJeP95TBIqS",
  "scope": "profile email"
}


3). Signature

Decoding JWT field:     o2VWFprGMxeqzo8d4uUTDQBbptMaGRhmz8TT977E4nnYasMC4wVkLFguv3jbqN1XLEomwiEnBigCqVT_NkS8-28UOKr_qLfeAk1pv9U8HYj1BfNfWb76abDQ63UkWHvQEIa2MGUVzIb3SihCFfu3A-LStjd1Um3gKo6BAI1tFT33rLErsBL5rgwwwa7GQW6wtx3udA5Alj4ziCJgBnpBXK5ZngD-PO1tiFdKOR9_LQbqE3pkwpE6-U1hPhro-KxDDPEtXxmOldJP-x5cBWhB477tcZ4hDR8oBXZlbe93X9OuArcVAPypa3SII3G2RVw-gz2IlCcsdXK-__Ls4eNfqg

00000000: a365 5616 9ac6 3317 aace 8f1d e2e5 130d  .eV...3.........
00000010: 005b a6d3 1a19 1866 cfc4 d3f7 bec4 e279  .[.....f.......y
00000020: d86a c302 e305 642c 582e bf78 dba8 dd57  .j....d,X..x...W
00000030: 2c4a 26c2 2127 0628 02a9 54ff 3644 bcfb  ,J&.!'.(..T.6D..
00000040: 6f14 38aa ffa8 b7de 024d 69bf d53c 1d88  o.8......Mi..<..
00000050: f505 f35f 59be fa69 b0d0 eb75 2458 7bd0  ..._Y..i...u$X{.
00000060: 1086 b630 6515 cc86 f74a 2842 15fb b703  ...0e....J(B....
00000070: e2d2 b637 7552 6de0 2a8e 8100 8d6d 153d  ...7uRm.*....m.=
00000080: f7ac b12b b012 f9ae 0c30 c1ae c641 6eb0  ...+.....0...An.
00000090: b71d ee74 0e40 963e 3388 2260 067a 415c  ...t.@.>3."`.zA\
000000a0: ae59 9e00 fe3c ed6d 8857 4a39 1f7f 2d06  .Y...<.m.WJ9..-.
000000b0: ea13 7a64 c291 3af9 4d61 3e1a e8f8 ac43  ..zd..:.Ma>....C
000000c0: 0cf1 2d5f 198e 95d2 4ffb 1e5c 0568 41e3  ..-_....O..\.hA.
000000d0: beed 719e 210d 1f28 0576 656d ef77 5fd3  ..q.!..(.vem.w_.
000000e0: ae02 b715 00fc a96b 7488 2371 b645 5c3e  .......kt.#q.E\>
000000f0: 833d 8894 272c 7572 beff f2ec e1e3 5faa  .=..',ur......_.

'''





# Inspect public JSON Web Key Set (JWKS)
curl -s \
    http://localhost:8093/realms/master/protocol/openid-connect/certs | \
jq .

'''

--> Each key has their own use, note sig vs enc

{
  "keys": [
    {
      "kid": "Tds394gVB3l7vIzxzELB8wC78--o1oSvaoi31sDTe2w",
      "kty": "RSA",
      "alg": "RS256",
      "use": "sig",
      "x5c": [
        "MIICmzCCAYMCBgGhh0QNgzANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYxMDI5MTA0NDA2WhcNMzYxMDI5MTA0NTQ2WjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDO/Su9GWNW0tcP2fiiKwy1z5k0EN86H+gjnkWmTgXNzjV6Le6Pnsx330o/Y1K1Lu4jaUGTaJvP4WMLES5cwpDIGdana1L3pbVTvRLaCkuHEPtwdecHhsdDeM1IwgBItZ0r+qBwCbgx46JIpox4SHQkfCjQKyFbkfaUqt9DwfJ6hf6d58gJuyqAiTVsSWq1GiNWQx9SX/brEeZEKqX5Mmq+TL/SJQvGuXokMGyxwom4pqpCPhF7XjKjuOwOgMTiexUHpbIpONMjp6ltCmBIOwfmxVXkIo9uBkQedR8d3FUM/JVNPIJeDyAinb98YOI3UkFF6LBJPUK6meGJyVjdUvY/AgMBAAEwDQYJKoZIhvcNAQELBQADggEBAJ7NDoYOxK0B3ldur9pNzYeicnPwYrgzfxjVTtPv3hkvjgVCQ3d8+5DSpAAvM85BX3vVT712rJrA/Eo3VBl0BAngYivFfMq1gqzvCuaM+F9SVYslIZOtgEFrvyn5FwCRf037z8gJQWWupO9Cq0r06siKTybROYnVEqYncySPQKuFFJEnb7kPoamsDU8g88WzgVIl3k/2uL4Cqno6OBSROdy7i8RzRIbkqdk/eAe//OKO0pBPM74phCfY+EXKpGVutXtPTiWpSuowdxUe63/YJGxJbGthc1Jkzy245CEYfYZJhVqrrjgMITxJ+OxdCHfvROgvgxR/If7Q9JK6MEJ2WWA="
      ],
      "x5t": "yeG-SXl_CKIHAPoFh3Y_yLB2BcE",
      "x5t#S256": "iC5om7XAw1_mkAEDGVVTH3IJ_U6CN3Kg2RYocoI239o",
      "n": "zv0rvRljVtLXD9n4oisMtc-ZNBDfOh_oI55Fpk4Fzc41ei3uj57Md99KP2NStS7uI2lBk2ibz-FjCxEuXMKQyBnWp2tS96W1U70S2gpLhxD7cHXnB4bHQ3jNSMIASLWdK_qgcAm4MeOiSKaMeEh0JHwo0CshW5H2lKrfQ8HyeoX-nefICbsqgIk1bElqtRojVkMfUl_26xHmRCql-TJqvky_0iULxrl6JDBsscKJuKaqQj4Re14yo7jsDoDE4nsVB6WyKTjTI6epbQpgSDsH5sVV5CKPbgZEHnUfHdxVDPyVTTyCXg8gIp2_fGDiN1JBReiwST1CupnhiclY3VL2Pw",
      "e": "AQAB"
    },
    {
      "kid": "nSTwChyEYwtS_4Rqp_hCpxuOfa_v38Y0MrQ3DjFod78",
      "kty": "RSA",
      "alg": "RSA-OAEP",
      "use": "enc",
      "x5c": [
        "MIICmzCCAYMCBgGhh0QOMTANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDDAZtYXN0ZXIwHhcNMjYxMDI5MTA0NDA2WhcNMzYxMDI5MTA0NTQ2WjARMQ8wDQYDVQQDDAZtYXN0ZXIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCriSkqq2OuJVWtWq19mxeEyKFseN5tTb3umDyPRMp7ybfbxrU7K+F77mQS0Opsij/x7ZjTKR2Aomlx5MAOqFVm5d1ZCJJ2wKNF9jDSgNaxxa32Pbzz2CG72P+L28kAuK/Iac2N7giAaJ3d8gkUkmkIOdbOJhCbs3IcE5RRc6Elb9dHr51Hz//feht+SgFA1/X6fWN1VTPBNx5zyXnbsLH0FeEHUH9/mMm9haTqfEOFtm8bmZP5syVbrhLy2NEJR6I+p4nukNecZXMCr390y0zBXBthFH9HcL/+Pmr5mlrHKKeD/lBFOpogEehogXt29uZV8TdQAz0OairxfcO92l7hAgMBAAEwDQYJKoZIhvcNAQELBQADggEBACkgEWAsn77/MehU4K28oXuTXTuAuDD+Mn7zmWmvZOVCJbxrU0VVeBC1TQvkIhpRpbpgslF9FSeOdLbttaRzsfKPkDJi+HIPsH1dyzG758auSu5hRsYhtG0zx9/ScbRwGv9Y9Sd6ZA2xPqOlTW//wPw/0xrNEJQKHhEHEf35ACcHK4a7PiTBGVuoZMWir5/M9riVeUla+r2LwfcII8BUpDzRVYdKDSJfcX2fEcEEcoDZubNVy67OOkiNiYoJYjDpbnFoZlseltIyhq5YNKeeMWchF3Nh+zvZiiiNRIeif3usMSaKeVI7FzcpbIi5tzXF3Nxdbx1eF96EEeHIZPWpJms="
      ],
      "x5t": "67SpaUrduPwfz2diRXD_ETofPyY",
      "x5t#S256": "nTEGnIR779jgniII_SvLmvb71fXxnfumbUqmOAYwwHs",
      "n": "q4kpKqtjriVVrVqtfZsXhMihbHjebU297pg8j0TKe8m328a1Oyvhe-5kEtDqbIo_8e2Y0ykdgKJpceTADqhVZuXdWQiSdsCjRfYw0oDWscWt9j2889ghu9j_i9vJALivyGnNje4IgGid3fIJFJJpCDnWziYQm7NyHBOUUXOhJW_XR6-dR8__33obfkoBQNf1-n1jdVUzwTcec8l527Cx9BXhB1B_f5jJvYWk6nxDhbZvG5mT-bMlW64S8tjRCUeiPqeJ7pDXnGVzAq9_dMtMwVwbYRR_R3C__j5q-Zpaxying_5QRTqaIBHoaIF7dvbmVfE3UAM9Dmoq8X3Dvdpe4Q",
      "e": "AQAB"
    }
  ]
}

'''


# Inspect realms
curl -sS \
    "$KC_URL/admin/realms" \
    -H "Authorization: Bearer $KC_TOKEN" |
jq -r '.[].realm'


'''

{
  "realm": "master",
  "enabled": true,
  "displayName": "Keycloak"
}

'''


# Post realm configuration
jq .realm keycloak-configs/machine-roles.realm.json
curl -sS -i \
    -X POST "$KC_URL/admin/realms" \
    -H "Authorization: Bearer $KC_TOKEN" \
    -H "Content-Type: application/json" \
--data-binary @keycloak-configs/machine-roles.realm.json

curl -sS \
    "$KC_URL/admin/realms" \
    -H "Authorization: Bearer $KC_TOKEN" \
| jq -r '.[].realm'


'''

HTTP/1.1 201 Created
Location: http://localhost:8093/admin/realms/machine-roles
Referrer-Policy: no-referrer
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: SAMEORIGIN
X-Robots-Tag: none
content-length: 0

machine-roles
master

'''



# Fetch and examine an access token from clients
SERVER_A_TOKEN=$(
    curl -s -X POST \
        "http://localhost:8093/realms/machine-roles/protocol/openid-connect/token" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials" \
        -d "client_id=server-a" \
        -d "client_secret=super-secret-server-a-key" \
    | jq -r '.access_token'
)

for field in $( echo $SERVER_A_TOKEN | sed 's/\./ /g' )
do
    echo -e "\n\nDecoding JWT Field:\t$field\n"
    echo $field | tr '_-' '/+' | base64 -d | jq
done


''' ---> While the Header & Signature fields are similar, claims in payload vary massively to previous JWT


1). JWT Header Field
Decoding JWT Field:     eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJlMjJpOS1DeWxObVVLYUFDdVFHX3VMdFZqQ3NTX2kxMEJsc3hmYVA4NXA0In0

{
  "alg": "RS256",
  "typ": "JWT",
  "kid": "e22i9-CylNmUKaACuQG_uLtVjCsS_i10BlsxfaP85p4"
}



2). JWT Payload Field
Decoding JWT Field:     eyJleHAiOjE3OTMyNzgzNjQsImlhdCI6MTc5MzI3ODA2NCwianRpIjoidHJydGNjOmY2YjRkOWE3LWIxNjUtZDM5Ni0zN2JjLWYwODQzZDE2ZmU1ZSIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3Q6ODA5My9yZWFsbXMvbWFjaGluZS1yb2xlcyIsImF1ZCI6WyJzZXJ2ZXItYiIsImFjY291bnQiXSwic3ViIjoiMjlhMGE2MGQtZDZjZS00NDJjLWExMjItMTQyOGM1NjhlZjQ0IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoic2VydmVyLWEiLCJhY3IiOiIxIiwicmVhbG1fYWNjZXNzIjp7InJvbGVzIjpbIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iLCJkZWZhdWx0LXJvbGVzLW1hY2hpbmUtcm9sZXMiXX0sInJlc291cmNlX2FjY2VzcyI6eyJzZXJ2ZXItYSI6eyJyb2xlcyI6WyJoYXNoIl19LCJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNsaWVudEhvc3QiOiIxNzIuMTguMC4xIiwicHJlZmVycmVkX3VzZXJuYW1lIjoic2VydmljZS1hY2NvdW50LXNlcnZlci1hIiwiY2xpZW50QWRkcmVzcyI6IjE3Mi4xOC4wLjEiLCJjbGllbnRfaWQiOiJzZXJ2ZXItYSJ9

Base fields are similar like:
    expirary, issuer, type, authorized party

Difference is 
Audience this instance is server-b & roles, so if this token is given to serverC.
    - The whole protocol of OIDC on OAUTH allows for a secure way to verify to say that the
        calling entity providing that token as serverC I can reject this, as I am serverC not B.
    - Then role aspect, serverB can say whether or not calling entity is allowed to call me.



The resource_access field represents the permission of serverA

Other fields here represent metadata around the token
    clientHost & Address represent the IP address that Keycloak saw


{
  "exp": 1793278364,
  "iat": 1793278064,
  "jti": "trrtcc:f6b4d9a7-b165-d396-37bc-f0843d16fe5e",
  "iss": "http://localhost:8093/realms/machine-roles",
  "aud": [
    "server-b",
    "account"
  ],
  "sub": "29a0a60d-d6ce-442c-a122-1428c568ef44",
  "typ": "Bearer",
  "azp": "server-a",
  "acr": "1",
  "realm_access": {
    "roles": [
      "offline_access",
      "uma_authorization",
      "default-roles-machine-roles"
    ]
  },
  "resource_access": {
    "server-a": {
      "roles": [
        "hash"
      ]
    },
    "account": {
      "roles": [
        "manage-account",
        "manage-account-links",
        "view-profile"
      ]
    }
  },
  "scope": "email profile",
  "email_verified": false,
  "clientHost": "172.18.0.1",
  "preferred_username": "service-account-server-a",
  "clientAddress": "172.18.0.1",
  "client_id": "server-a"
}



3). JWT Signature Field

Decoding JWT Field:     m6swS_l2w_CeATHn9uZ1FCFz7rzw_cxsbDg2_-4AD_HCkU2bOi_P_OMZvhsYUfeDkviH0bJU4hvuelqa9WjxxPa__6wE8sUPqvk7PjHdvM72ygQJcDQA9bkgkm26AIeu_cPJnhiIMwXZyGyqk0oV8swhzXBcZutG5Gd6esSiPIfTLku1ROiBLjqKjSeU-R_9e9zwrj6hPChJRwPOUxaIXBAgLraBSqAp1j9xc23iUkMg43E12jQZ-dYbIwsdmLjIY8T7iC29xqsldcOvg6M3PltoWeNE--drwvwVAPwjnUaFuwF4tugthL3iB3IUxBWkqv3d3070AXmgh5qN2vT7eQ


'''
