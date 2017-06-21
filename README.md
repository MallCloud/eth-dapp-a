# eth-dapp-a
Ethereum Decentralized Application - A

## Working

1. create a new notebook using some template.
2. save the notebook into db or cloud(or any other location)
3. store the location of notebook into contract.
4. the contract will call an api that returns the location of notebook of each user.
5. the login system will store the notebook locations of each user.

## How this works for a user:

1. user logs in
2. user creates a notebook on the ui / provides a dataset to the ui.
3. the notebook/dataset are stored in some location.
4. the location is stored in the user's information area.
5. the contract gets updated by user's data getting fetched into notebook contract
6. now the document is in the blockchain

### Extra Information - Current System

Blockchain network requires some gas every time state of the stored information is changed. We are storing the location of notebook/dataset into the blockchain. Hence, creation and changing the location of storage(which will need update into the storage url into contract) will require gas. This means that creation and changing location of storage will need `Eth`, which is similar to bitcoin.
