pragma solidity ^0.4.25;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner;                                      // Account used to deploy contract
    bool private operational = true;                                    // Blocks all state changes throughout the contract if false

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/
    struct airline {
        string name;
        address contractAddress;
        bool isFunded;
        uint256 totalVotes;
    }

    uint256 public totalRegisteredAirlines = 0;
    mapping(address=>airline) public registeredAirlines;

    //before adding to the data contract registered airlines must have complete votes
    mapping(address=>airline) public registrationQueue;
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
        registeredAirlines[msg.sender] = false;
        totalRegisteredAirlines += 1;
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
        require(registeredAirlines[msgSender] != address(0), "Caller is not authorized to vote");
        require(airlineVotes[airlineAddress][msgSender] == address(0), "Caller has already voted for this airline");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

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

   /**
    * @dev Add an airline to the registration queue
    *      Can only be called from FlightSuretyApp contract
    *
    */   
    function registerAirline
                            (
                                airline airlineToAdd
                            )
                            public
                            requireIsOperational
    {
        registeredAirlines[airlineAddress] = airlineToAdd;
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

        registrationQueue[airlineAddress] = Airline({
            name: name,
            airlineAddress: airlineAddress,
            isFunded: false,
            voteCounter: 1
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
        if (pendingAirlines[airlineAddress].totalVotes >= totalRegisteredAirlines.div((2)) || totalRegisteredAirlines < 4){
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

        registeredAirlines[airlineAddress].isFunded = true;
        totalFunds = totalFunds.add(amount);
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

