pragma solidity ^0.4.0;

contract DataMarketplace {   // data marketplace that hold all business environments

    BusinessEnvironment[] public businessEnvironments;   // public variables

    mapping (address => address[]) public datasets_keys_from_seller;  // mappings
    mapping (address => string[]) public datasets_names_from_seller;


    function DataMarketplace() payable {  // constructor

    }
                     // adds business environment on marketplace
    function AddBusinessEnvironmentToMarketplace(address _businessEnvironmentAddress) payable {
        businessEnvironments.push(BusinessEnvironment(_businessEnvironmentAddress));
    }

    function () payable {   // callback function
        throw;
    }

}

contract BusinessEnvironment {       // business environment specific for a solution

    string public environmentName;                // public variables
    DatasetTemplate public datasetTemplate;

    function BusinessEnvironment(string _environmentName) payable {   // constructor
        environmentName = _environmentName;
    }

    function AddDatasetTemplate(address _datasetTemplateAddress) payable {   // add dataset template on environment
        datasetTemplate = DatasetTemplate(_datasetTemplateAddress);
    }

}


contract DatasetTemplate {          // dataset template contract

    address templateUniqueKey;      // public variables
    Dataset[] public datasets;

    mapping (address => address[]) public uniqueKeysFromUser;  // mappings

    function DatasetTemplate(address _templateUniqueKey) payable {  // constructor
        templateUniqueKey = _templateUniqueKey;
    }

    function DownloadTemplate() payable {       // function adds relation betwen template key and user
        uniqueKeysFromUser[msg.sender].push(templateUniqueKey);
    }

    function AddDatasetFirstVersion(address _datasetAddress) payable {   // add a version of dataset written on top of this template
        bool userHasUniqueKey = false;
        for (uint i = 0; i < uniqueKeysFromUser[msg.sender].length; i++){
            if (uniqueKeysFromUser[msg.sender][i] == templateUniqueKey){  // check if user is able to add version
                userHasUniqueKey = true;
            }
        }
        if (userHasUniqueKey){
            datasets.push(Dataset(_datasetAddress)); // add dataset version on this template
        }
    }

}


contract Dataset {      // dataset contract

    Dataset[] public derivedDatasets;      // public variables
    address public datasetUniqueKey;
    address public templateItemKey;
    address public previousDatasetKey;
    address public previousSellerAddress;
    address public sellerAddress;
    string public name;
    uint public price;
    uint public usageFee;
    address[] public usersWithAccess;
    address[] public owners;
    uint public numBuyers;
    uint public numBuyersUses;
    bool public isVersion = false;
    uint public versionPercentage = 50;

    struct Buyer {             // structs used to control
        uint amount;
        address eth_address;
    }

    struct BuyerUse {
        uint amount;
        address eth_address;
    }

    mapping (uint => BuyerUse) public buyersUses;        // mappings used to control
    mapping (uint => Buyer) public buyers;
    mapping (address => bool) public accessLevelFromUser;
    mapping (address => address[]) public datasetUniqueKeysFromUser;
    mapping (address => uint) public pendingWithdrawals;

    modifier onlyIfPayingEnoughForBuying { if (msg.value >= price){ _;}} // modifiers to restric functions access
    modifier onlyIfPayingEnoughForUsing { if (msg.value >= usageFee){ _;}}
    modifier onlySeller { if (msg.sender == sellerAddress){ _;}}
    modifier onlyBuyerWithAccess { if (accessLevelFromUser[msg.sender]){ _;}}

    function Dataset(address _sellerAddress, address _uniqueKey, string _name, uint _price, uint _usageFee) payable {
        sellerAddress = _sellerAddress;
        datasetUniqueKey = _uniqueKey;            // constructor
        name = _name;
        price = _price;
        usageFee = _usageFee;
    }

    function AddUniqueKeyFromTemplate(address _templateItemKey) payable {  // add key from template base (if it is first version)
        templateItemKey = _templateItemKey;
    }

    function DownloadDataset() payable {   // adds reation between user and dataset key
        datasetUniqueKeysFromUser[msg.sender].push(datasetUniqueKey);
    }

    function AddUniqueKeyFromLastDataset(address _previousDatasetKey){  // add key from previous dataset (if it is a versioned dataset)
        previousDatasetKey = _previousDatasetKey;
    }

    function Buy() payable onlyIfPayingEnoughForBuying {  // buy function
        buyers[numBuyers] = Buyer(msg.value, msg.sender);   // adds new buyer to list
        numBuyers++;

        accessLevelFromUser[msg.sender] = true;   // updates buyer access
        usersWithAccess.push(msg.sender);
    }

    function WithdrawPayments() onlySeller {  // withdraw payments (accessible only by seller)
        if(!isVersion){                       // if it is not version, receive full amount
            for (uint i = 0; i < numBuyers; ++i) {
                var a = sellerAddress.send(buyers[i].amount);
                buyers[i].amount = 0;
            }
            for (uint j = 0; j < numBuyersUses; ++j) {
                var b = sellerAddress.send(buyersUses[j].amount);
                buyersUses[j].amount = 0;
            }
        }
        else {  // if it is a version, receive partial amount and previous seller receives the other part
            for (uint k = 0; k < numBuyers; ++k) {
                var c = sellerAddress.send(buyers[k].amount*(1-versionPercentage/100));
                var e = previousSellerAddress.send(buyers[k].amount*(versionPercentage/100));
                buyers[k].amount = 0;
            }
            for (uint m = 0; m < numBuyersUses; ++m) {
                var d = sellerAddress.send(buyersUses[m].amount*(1-versionPercentage/100));
                var f = previousSellerAddress.send(buyersUses[m].amount*(versionPercentage/100));
                buyersUses[m].amount = 0;
            }
        }      // this function is used recursively to make proportional payments for every seller on the tree
    }

    function getContractBalance() constant returns (uint) {  // continuously display contract balance
        return this.balance;
    }

    function GrantAcessToBuyer(address buyer) onlySeller {  // grant access to buyer manually
        accessLevelFromUser[buyer] = true;
        usersWithAccess.push(buyer);
    }

    function RevokeAccessFromBuyer(address buyer) onlySeller {  // revoke access from buyer manually
        accessLevelFromUser[buyer] = false;
    }

    function Use() payable onlyBuyerWithAccess onlyIfPayingEnoughForUsing {  // pay for dataset usage
        bool firstUse = true;
        for (uint i = 0; i < numBuyersUses; i++) {        // check if it is first use
            if (msg.sender == buyersUses[i].eth_address){
                firstUse = false;
            }
        }
        if(firstUse){       // if it is first use, adds user to list
            buyersUses[numBuyersUses] = BuyerUse(msg.value, msg.sender);
            numBuyersUses++;
        }
        else {
            for (uint j = 0; j < numBuyersUses; j++) {  // if it is not first use, just update amount to be paid
                if (msg.sender == buyersUses[j].eth_address){
                    buyersUses[j].amount += msg.value;
                }
            }
        }
    }

    function VersionDataset(address _previousSellerAddress) payable {  // specify versioned dataset and previous seller
        isVersion = true;
        previousSellerAddress = _previousSellerAddress;
    }

    function AddDatasetVersion(address _derivedDatasetAddress) payable {  // adds dataset version on top of this dataset
        bool userHasUniqueKey = false;
        for (uint i = 0; i < datasetUniqueKeysFromUser[msg.sender].length; i++){
            if (datasetUniqueKeysFromUser[msg.sender][i] == datasetUniqueKey){
                userHasUniqueKey = true;                               // check if user has dataset key
            }
        }
        if (userHasUniqueKey){
            derivedDatasets.push(Dataset(_derivedDatasetAddress));  // adds dataset version to list
        }
    }
}
