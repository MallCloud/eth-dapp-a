// web3 is an Ethereum client library
const Web3 = require('web3');
const web3 = new Web3();

web3.setProvider(new web3.providers.HttpProvider('http://localhost:8545'));

// This file is generated by the Solidity compiler to easily interact with
// the contract using the web3 library.
const datasetAbi = require('../solidity/build/contracts/Dataset.json').abi;
const DatasetContract = web3.eth.contract(datasetAbi);

module.exports = DatasetContract;