var Login = artifacts.require("./Login.sol");
var DataMarketPlace = artifacts.require("./DataMarketPlace.sol");
var NotebookMarketPlace = artifacts.require("./NotebookMarketPlace.sol");

module.exports = function(deployer) {
  deployer.deploy(Login);
  deployer.deploy(DataMarketPlace);
  deployer.deploy(NotebookMarketPlace);
};
