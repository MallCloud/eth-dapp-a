pragma solidity ^0.4.0;

/**
 * DOCUMENTATION
 *
 * Most of the interface of NotebookMarketplace is similar to DatasetMarketplace.
 * This is because they are based on same concept of sharing.
 * On the other hand, there is some change caused by the payment utility in both contracts.
 * Since datasets can be a paid service while notebooks will not be,
 * there is no need for providing buying or selling functions in this contract.
 * Also, notebooks will get compensations from people who wish to use the algorithm.
 * So, a compensation division part will have to be added to the contract.
 * The compensation model hasn't been finalized as of yet, so I am using an extremely
 * basic model that doesn't reflect the final system.
 *
 * There is a new feature added in this contract which is in testing for now.
 * The notebooks can be shared for a specific period of time that shall be mentioned
 * by the original author.
 * This feature will enable a contest like environment to be created in the marketplace.
 *
 * I have left some code from DatasetMarketplace that isn't required here in comments.
 * This is for my personal benefit to easily observe the changes.
 * They aren't actually of any significance here,
 * and can be removed according to reader's preference.
 */

/**
 * NOTES
 * 1. https://ethereum.stackexchange.com/questions/6121/parse-json-in-solidity
 * 2. https://github.com/oraclize/docs/blob/master/source/includes/_fabric.md
 */

/**
 * Usage Information
 *
 * The code has been added into the truffle environment and the contracts may
 * utilize this framework's environment for running and testing contracts.
 *
 * Here are some important commands :
 *
 *
 * for compiling contracts code
 * $ truffle compile
 *
 * for migration of contract code to a server
 * $ truffle migrate
 *
 * for running tests
 * $ truffle test
 *
 * for building development version of app with frontend
 * $ truffle build
 *
 * for running a console with contract objects instantiated into it
 * $ truffle console
 *
 * intelligent compilation of contract code
 * $ truffle compile
 *
 * helper command for scaffolding new contract code
 * $ truffle create:contract $(contract_name)
 *
 * helper command for scaffolding new test code
 * $ truffle create:test $(test_name)
 *
 * execute a javascript file within truffle env
 * $ truffle exec /path/to/my/script.js
 *
 * serve the dapp onto a local server
 * $ truffle serve
 */

// import {SchedulerInterface} from 'contracts/SchedulerInterface.sol';
import 'contracts/oraclizeAPI_0.4.sol';
import 'contracts/strings.sol';

// data marketplace that hold all business environments
contract NotebookMarketplace {
    // public variables
    BusinessEnvironment[] public businessEnvironments;

    // mappings
    mapping (address => address[]) public notebook_keys_from_author;
    mapping (address => string[]) public notebook_names_from_author;

    // constructor
    function NotebookMarketplace() payable {

    }

    // adds business environment on marketplace
    function AddBusinessEnvironmentToMarketplace(address _businessEnvironmentAddress) payable {
        businessEnvironments.push(BusinessEnvironment(_businessEnvironmentAddress));
    }

    // callback function
    function () payable {
        throw;
    }

}

// business environment specific for a solution
contract BusinessEnvironment {
    // public variables
    string public environmentName;
    NotebookTemplate public notebookTemplate;

    // constructor
    function BusinessEnvironment(string _environmentName) payable {
        environmentName = _environmentName;
    }

    // add notebook template on environment
    function AddNotebookTemplate(address _notebookTemplateAddress) payable {
        notebookTemplate = NotebookTemplate(_notebookTemplateAddress);
    }

}

// notebook template contract
contract NotebookTemplate {
    // public variables
    address templateUniqueKey;
    Notebook[] public notebooks;

    // mappings
    mapping (address => address[]) public uniqueKeysFromUser;

    // constructor
    function NotebookTemplate(address _templateUniqueKey) payable {
        templateUniqueKey = _templateUniqueKey;
    }

    // function adds relation betwen template key and user
    function DownloadTemplate() payable {
        uniqueKeysFromUser[msg.sender].push(templateUniqueKey);
    }

    // add a version of notebook written on top of this template
    function AddNotebookFirstVersion(address _notebookAddress) payable {
        bool userHasUniqueKey = false;
        for (uint i = 0; i < uniqueKeysFromUser[msg.sender].length; i++){
            // check if user is able to add version
            if (uniqueKeysFromUser[msg.sender][i] == templateUniqueKey){
                userHasUniqueKey = true;
            }
        }
        if (userHasUniqueKey){
            // add notebook version on this template
            notebooks.push(Notebook(_notebookAddress));
        }
    }

}

// notebook contract
contract Notebook {
/*contract Notebook is usingOraclize {*/
    // public variables
    Notebook[] public derivedNotebooks;
    address public notebookUniqueKey;
    address public templateItemKey;
    address public previousNotebookKey;
    address public previousAuthorAddress;
    address public authorAddress;
    string public name;
    uint public price;
    uint public usageFee;
    address[] public usersWithAccess;
    address[] public owners;
    uint public numUsers;
    uint public numUsersUses;
    bool public isVersion = false;
    uint public versionPercentage = 50;
    bool public changeInAccuracyRates;

    // scheduler variables for accessing functions
    /**
    SchedulerInterface constant scheduler = SchedulerInterface(0x6c8f2a135f6ed072de4503bd7c4999a1a17f824b);
    uint public lockedUntil;
    address recipient;
    **/

    // oraclize events to notify changes
    /*
     * event newOraclizeQuery(string description);
     * event newCollabAttr(string attr_info);
     */

     /**
      * Event that creates a new notebook; is handled by api
      * @address : address of the user that sends the request
      * @challenge : string that contains details for notebook generation
      */
    event CreateNewNotebook(address sender, string challenge);
    /**
     * Event that asks for access for read/edit rights of a Notebook
     * @address : address of the user that requires access
     */
    event AccessLevelFromUser(address sender);
    /**
     * Event that adds information regarding versioning into notebooks
     * @address : address of the person who made changes into notebook
     */
    event AddNotebookVersion(address author);

    // structs used to control
    struct User {
        uint amount;
        address eth_address;
    }

    /**
    struct UserUse {
        uint amount;
        address eth_address;
    }
    **/

    // mappings used to control
    // mapping (uint => UserUse) public usersUses;
    mapping (uint => User) public users;
    mapping (address => bool) public accessLevelFromUser;
    mapping (address => address[]) public notebookUniqueKeysFromUser;
    // mapping (address => uint) public pendingWithdrawals;

    // modifiers
    // modifier onlyIfPayingEnoughForBuying { if (msg.value >= price){ _;}}
    // modifier onlyIfPayingEnoughForUsing { if (msg.value >= usageFee){ _;}}
    modifier onlyAuthor { if (msg.sender == authorAddress){ _;}}
    modifier onlyUserWithAccess { if (accessLevelFromUser[msg.sender]){ _;}}

    // constructor
    // function Notebook(address _authorAddress, address _uniqueKey, string _name, uint _price, uint _usageFee) payable {
    function Notebook(address _authorAddress, address _uniqueKey, string _name) payable {
        authorAddress = _authorAddress;
        notebookUniqueKey = _uniqueKey;
        name = _name;
        // price = _price;
        // usageFee = _usageFee;

        /*update();*/
    }

    // function for updating money each author gets
    /**
    * This function can be implemented after the user information
    * contracts have been created and they are accessible from this contract.
    */
    /*function newCollabAttr(string attr_info) {
        // pass
    }

    // callback function for ostracize update()
    function __callback(bytes32 myid, string attr_info) {
        if (msg.sender != oraclize_cbAddress()) {
          // just to be sure the calling address is the Oraclize authorized one
          throw;
        }

        newCollabAttr(attr_info);
    }

    // updates information by fetching from ostracize
    function update() payable {
        string memory URL;
        URL = strConcat("https://api.mallcloud.com/0/public/username?notebook_id=", notebookUniqueKey);
        bytes32 myid = oraclize_query("URL", strConcat("json(", URL, ")"));
    }*/

    // add key from template base (if it is first version)
    function AddUniqueKeyFromTemplate(address _templateItemKey) payable {
        templateItemKey = _templateItemKey;
    }

    // adds reation between user and notebook key
    function DownloadNotebook() payable {
        notebookUniqueKeysFromUser[msg.sender].push(notebookUniqueKey);
    }

    // add key from previous notebook (if it is a versioned notebook)
    function AddUniqueKeyFromLastNotebook(address _previousNotebookKey){
        previousNotebookKey = _previousNotebookKey;
    }

    // buy function
    /**
    function Buy() payable onlyIfPayingEnoughForBuying {
        // adds new user to list
        users[numUsers] = User(msg.value, msg.sender);
        numUsers++;

        // updates user access
        accessLevelFromUser[msg.sender] = true;
        usersWithAccess.push(msg.sender);
    }
    **/


    // withdraw payments (accessible only by author)
    /**
    function WithdrawPayments() onlyAuthor {
        // if it is not version, receive full amount
        if(!isVersion){
            for (uint i = 0; i < numUsers; ++i) {
                var a = authorAddress.send(users[i].amount);
                users[i].amount = 0;
            }
            for (uint j = 0; j < numUsersUses; ++j) {
                var b = authorAddress.send(usersUses[j].amount);
                usersUses[j].amount = 0;
            }
        }
        // if it is a version, receive partial amount and previous author receives the other part
        else {
            for (uint k = 0; k < numUsers; ++k) {
                var c = authorAddress.send(users[k].amount*(1-versionPercentage/100));
                var e = previousAuthorAddress.send(users[k].amount*(versionPercentage/100));
                users[k].amount = 0;
            }
            for (uint m = 0; m < numUsersUses; ++m) {
                var d = authorAddress.send(usersUses[m].amount*(1-versionPercentage/100));
                var f = previousAuthorAddress.send(usersUses[m].amount*(versionPercentage/100));
                usersUses[m].amount = 0;
            }
            // this function is used recursively to make proportional payments for every author on the tree
        }
    }
    **/


    // continuously display contract balance
    /**
    function getContractBalance() constant returns (uint) {
        return this.balance;
    }
    **/

    // grant access to user manually
    function GrantAcessToUser(address user) onlyAuthor {
        accessLevelFromUser[user] = true;
        usersWithAccess.push(user);
    }

    // revoke access from user manually
    function RevokeAccessFromUser(address user) onlyAuthor {
        accessLevelFromUser[user] = false;
    }

    // pay for notebook usage
    /**
    function Use() payable onlyUserWithAccess onlyIfPayingEnoughForUsing {
        bool firstUse = true;
        // check if it is first use
        for (uint i = 0; i < numUsersUses; i++) {
            if (msg.sender == usersUses[i].eth_address){
                firstUse = false;
            }
        }
        // if it is first use, adds user to list
        if(firstUse){
            usersUses[numUsersUses] = UserUse(msg.value, msg.sender);
            numUsersUses++;
        }
        else {
            // if it is not first use, just update amount to be paid
            for (uint j = 0; j < numUsersUses; j++) {
                if (msg.sender == usersUses[j].eth_address){
                    usersUses[j].amount += msg.value;
                }
            }
        }
    }
    **/

    // specify versioned notebook and previous author
    function VersionNotebook(address _previousAuthorAddress) payable {
        isVersion = true;
        previousAuthorAddress = _previousAuthorAddress;
    }

    // adds notebook version on top of this notebook
    function AddNotebookVersion(address _derivedNotebookAddress) payable {
        bool userHasUniqueKey = false;
        for (uint i = 0; i < notebookUniqueKeysFromUser[msg.sender].length; i++){
            if (notebookUniqueKeysFromUser[msg.sender][i] == notebookUniqueKey){
                // check if user has notebook key
                userHasUniqueKey = true;
            }
        }
        if (userHasUniqueKey){
            // adds notebook version to list
            derivedNotebooks.push(Notebook(_derivedNotebookAddress));
        }
    }
}
