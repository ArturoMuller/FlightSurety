pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false
    address private authorizedCaller;                                   // Address of the app authorized to make calls here
    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    struct airlineType {
        string name;
        address contractAddress;
        bool isFunded;
        uint256 totalVotes;
        uint256 totalFunds;
    }

    uint256 public totalRegisteredAirlines = 0;
    mapping(address=> airlineType) public registeredAirlines;

    //before adding to the data contract registered airlines must have complete votes
    mapping(address=> airlineType) public registrationQueue;
    mapping(address=>mapping(address => bool)) public airlineVotes;

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor
                                (
                                ) 
                                public 
    {
        contractOwner = msg.sender;
        registeredAirlines[msg.sender] = airlineType({
                name: "airOwner",
                contractAddress: contractOwner,
                isFunded: false,
                totalVotes: 0,
                totalFunds: 0
            });
        totalRegisteredAirlines =  totalRegisteredAirlines.add(1);
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "operational" boolean variable to be "true"
    *      This is used on all state changing functions to pause the contract in 
    *      the event there is an issue that needs to be fixed
    */
    modifier requireIsOperational() 
    {
        require(operational, "Contract is currently not operational");
        _;  // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
    * @dev Checks if the msg sender is allowed to cast a vote
    */
    function canVote(address msgSender, address airlineAddress){
        require(registeredAirlines[msgSender].contractAddress == msgSender, "Caller is not authorized to vote");
        require(airlineVotes[airlineAddress][msgSender] != true, "Caller has already voted for this airline");
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
    * @dev Authorize external flightSuretyApp contract to use this contract
    */
    function authorizeCaller(address externalContractAddress) external requireContractOwner
    {
        authorizedCaller = externalContractAddress;
    }
    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */      
    function isOperational() 
                            public 
                            view 
                            returns(bool) 
    {
        return operational;
    }


    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */    
    function setOperatingStatus
                            (
                                bool mode
                            ) 
                            external
                            requireContractOwner 
    {
        operational = mode;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/
    function isAirline(address airlineAddress)
    public
    returns (bool)
    {
        airlineType registeredAirline = registeredAirlines[airlineAddress];
        if(registeredAirline.contractAddress != 0) {
            return registeredAirline.isFunded;
        }
        return false;
    }
   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                airlineType airlineToAdd
                            )
                            public
                            requireIsOperational
    {
        registeredAirlines[airlineToAdd.contractAddress] = airlineToAdd;
        totalRegisteredAirlines = totalRegisteredAirlines.add(1);
    }

    function addToRegistrationQueue
    (
        string name,
        address airlineAddress
    )
    external
    requireIsOperational
    {

        registrationQueue[airlineAddress] = airlineType({
            name: name,
            contractAddress: airlineAddress,
            isFunded: false,
            totalVotes: 1,
            totalFunds: 0
            });
    }

    function vote
    (
        address airlineAddress
    )
    external
    requireIsOperational
    returns (uint256)
    {
        airlineVotes[airlineAddress][msg.sender] = true;
        registrationQueue[airlineAddress].totalVotes = registrationQueue[airlineAddress].totalVotes.add(1);
        if (registrationQueue[airlineAddress].totalVotes >= totalRegisteredAirlines.div((2)) || totalRegisteredAirlines < 4){
            registerAirline(registrationQueue[airlineAddress]);
            delete registrationQueue[airlineAddress];
            return registrationQueue[airlineAddress].totalVotes;
        }
        return registrationQueue[airlineAddress].totalVotes;
    }

    function fundAirline
    (
        address airlineAddress,
        uint256 amount
    )
    external
    payable
    requireIsOperational
    {
        registeredAirlines[airlineAddress].totalFunds.add(amount);
        if (registeredAirlines[airlineAddress].totalFunds > 10){
            registeredAirlines[airlineAddress].isFunded = true;
        }
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy
                            (                             
                            )
                            external
                            payable
    {

    }

    /**
     *  @dev Credits payouts to insurees
    */
    function creditInsurees
                                (
                                )
                                external
                                pure
    {
    }
    

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
    */
    function pay
                            (
                            )
                            external
                            pure
    {
    }

   /**
    * @dev Initial funding for the insurance. Unless there are too many delayed flights
    *      resulting in insurance payouts, the contract should be self-sustaining
    *
    */   
    function fund
                            (   
                            )
                            public
                            payable
    {
    }

    function getFlightKey
                        (
                            address airline,
                            string memory flight,
                            uint256 timestamp
                        )
                        pure
                        internal
                        returns(bytes32) 
    {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
    * @dev Fallback function for funding smart contract.
    *
    */
    function() 
                            external 
                            payable 
    {
        fund();
    }


}

