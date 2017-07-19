# Ethereum based Notebook & Database Manager

## Parts of the Application

1. Contracts

The contracts for the ethereum dapp (decentralized application) have been written in Solidity.

2. Backend

The backend of the application comprises of the API endpoints that are used to access blockchain in the network, send/receive data and for confirmation of identity.

3. Frontend

This hasn't been developed but its the face of the application.

## Installation

Install these software :

1. Geth
2. TestRPC
3. Metamask
4. Truffle

Here are the commands for installation (these are for Linux; for other OS, please check online) :


## Introduction

The Ethereum Framework is essentially an immutable network that is made up of nodes. These nodes contain blocks, and the blocks contain contracts. The network utilizes several algorithms to optimize the graph. The contracts are compiled and the binaries are deployed to the network. The network is a remote system which is employed by combining every client that wishes to connect and become a node. The procedure involves 'Mining' the network. The contracts can only be contacted using an RPC call. This is because the contracts are distributed all across the framework and there is no single point of contact with the contracts. A javascript implementation for making RPC calls to the contracts is available and is called 'Web3.js'.

### How the dapp works

1. The contracts are compiled and deployed to the ethereum network.
2. When a contract is deployed, a hashed key is returned. This key signifies the location of the point-of-contact for the contract in the network.
3. This key is used by 'Web3.js' based js code to contact with the contracts.
4. API calls are made in order to send/receive data to/from contracts.

### API (server side)

#### Authentication

1. '/login'

input : (req)
<br>output : (res)

Takes in the request from the client, and then sends the required response. The checking is done by observing the validity of the address sent to the server.
Response comprises of a JSON Token with a timed validity sequence.

2. '/finishLogin'

input : (validateJwt, res)
<br>output : (res)

Takes in the 'validateJwt' function's output along with the request and confirms or denies login into the account.

3. '/createNB'

input : (req, configFile.conf)
<br>output : (res)

Takes in the request along with a configuration file. The configuration file should contain the location where the notebook is stored along with any other details that are valid and required by the server.
Response comprises of the success or failure confirmation with an error message, if needed.

4. '/deleteNB'

input : (req)
<br>output : (res)

Takes in the request for deletion of the notebook along with any other details that are needed.
Response comprises of the success or failure confirmation with an error message, if needed.

5. '/askPermNB'

input : (req)
<br>output : (res)

Takes in the request for asking of permission for access to a notebook along with other details that are needed.
Response comprises of the success or failure confirmation with an error message, if needed.

6. '/createData'

input : (req, configFile.conf)
<br>output : (res)

Takes in the request along with a configuration file. The configuration file should contain the location where the data is stored along with any other details that are valid and required by the server.
Response comprises of the success or failure confirmation with an error message, if needed.

7. '/deleteData'

input : (req)
<br>output : (res)

Takes in the request for deletion of the data along with any other details that are needed.
Response comprises of the success or failure confirmation with an error message, if needed.

8. '/askPermData'

input : (req)
<br>output : (res)

Takes in the request for access rights and download rights to the Data.
Response comprises of the success or failure confirmation with an error message, if needed.

9. '/buyData'

input : (req)
<br>output : (res)

Data can be bought by using this api. The request comprises of information needed for buying of data.
<!-- TODO : Implement a version which can also take a contract along with a request parameter  -->
<!-- This will allow people to write standing contracts for buying ownership for some parts of data -->
Response comprises of the success or failure confirmation with an error message, if needed.


##### Sample API responses

1. **POST** : /login
```
response {
    challenge : 'a collision resistant id',
    jwt : json token
}
```
Error Status Codes :

400 : Address not found in registry. Register first, login later.


2. **POST** : /finishLogin
```
response {
    jwt : token,
    address : req.jwt.address
}
```
Error Status Codes :

400 : Address not found in registry. Register first, login later.
<br>202 : HTTP request accepted, but operation not completed.


3. **POST** : /createNB
```
response {
    'location' : URI of the notebook
}
```
Error Status Codes :

401 : Unauthorized Access, not granted


4. **POST** : /deleteNB
```
response {
    'success' : 'true'
}
```
Error Status Codes :

400 : Notebook not found
<br>401 : Unauthorized access
<br>202 : request accepted, but operation not completed


5. **POST** : /askPermNB
```
response {
    'access' : true,
    'key' : 'hashed key for signing'
}

response {
    'access' : false
}
```
Error Status Codes :

400 : Notebook not found
<br>202 : request accepted, but operation not completed


6. **POST** : /createData
```
response {
    'location' : URI of the notebook
}
```
Error Status Codes :

401 : Unauthorized Access, not granted


7. **POST** : /deleteData
```
response {
    'success' : 'true'
}
```
Error Status Codes :

400 : Notebook not found
<br>401 : Unauthorized access
<br>202 : request accepted, but operation not completed


8. **POST** : /askPermData
```
response {
    'access' : true,
    'key' : 'hashed key for signing'
}

response {
    'access' : false
}
```
400 : Notebook not found
<br>202 : request accepted, but operation not completed


9. **POST** : /buyData
```
response {
    'permission' : true,
    'location' : 'URI of data'
}

response {
    'permission' : false
}
```
Error Status Codes :

400 : Notebook not found
<br>401 : Unauthorized access
<br>202 : request accepted, but operation not completed
