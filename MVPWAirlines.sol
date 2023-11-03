// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error OnlyAdminError();
error CallError();
error InvalidAddressError();
error AllowanceError();
error Max4TicketsError(uint numOfTickets);

contract MVPWAirlines {

    struct Airplane {
        uint economy; // available economy seats
        uint firstclass; // available firstclass seats
        bool isActive; // not on hold
        uint[] flights; // previous flights IDs
    }

    struct Purchase {
        uint economy;
        uint firstclass;
        bool isDone;
    }

    struct Flight {
        string destination;
        uint airplaneID; 
        uint departure; // departure time
        uint economy; // available economy seats left
        uint firstclass; // available firstclass seats left 
        uint economyPrice; // economy ticket price
        uint firstclassPrice; // firstclass ticket price
        mapping(address => Purchase) tickets; // user => purchased tickets
    }

    address public admin;
    address public newAdmin;
    address private MVPWAirlinesAddress = 0x71bDd3e52B3E4C154cF14f380719152fd00362E7;
    IERC20 public MVPWAirlinesToken;
    uint public airplaneCnt; // Airplane counter
    mapping(uint => Airplane) public airplanes; // airplaneID => airplane
    uint public flightCnt; // Flight counter
    mapping(uint => Flight) public flights; // flightID => flight

    event OwnershipTransferred(address oldAdmin, address newAdmin);
    event AcceptOwnership();
    event AirplaneRegistered(uint airplaneID, uint economySeats, uint firstclassSeats);
    event AirplaneOnHold(uint airplaneID);
    event AirplaneActivate(uint airplaneID);
    event FlightAnnounced(string destination, uint airplaneID, uint departure, uint economyPrice, uint firstclassPrice);
    event TicketsPurchased(uint flightID, uint economyTickets, uint firstclassTickets, uint price);
    event TicketsCanceled(uint flightID, uint numOfTickets);

    modifier onlyAdmin {
        if (msg.sender != admin) revert OnlyAdminError();
        _;
    }

    constructor () {
        airplaneCnt = 0;
        flightCnt = 0;
        admin = msg.sender;
        MVPWAirlinesToken = IERC20(MVPWAirlinesAddress);
    }

    function transferOwnership(address _newAdmin) external onlyAdmin {
        if(_newAdmin == address(0)) revert InvalidAddressError();
        newAdmin = _newAdmin;
        emit AcceptOwnership();
    }

    function acceptOwnership() external {
        if(msg.sender != newAdmin) revert InvalidAddressError();
        address oldAdmin = admin;
        admin = newAdmin;
        emit OwnershipTransferred(oldAdmin, newAdmin);
    }

    function registerAirplane(uint economy, uint firstclass) external onlyAdmin {
        airplanes[airplaneCnt++] = Airplane(economy, firstclass, true, new uint[](0));
        emit AirplaneRegistered(airplaneCnt - 1, economy, firstclass);
    }

    function putAirplaneOnHold(uint id) external onlyAdmin {
        airplanes[id].isActive = false;
        emit AirplaneOnHold(id);
    }

    function activateAirplane(uint id) external onlyAdmin {
        airplanes[id].isActive = true;
        emit AirplaneActivate(id);
    }

    function announceFlight(
        uint airplaneID, 
        string calldata destination, 
        uint departure, 
        uint economyPrice, 
        uint firstclassPrice) external onlyAdmin 
    { 
        Airplane memory airplane = airplanes[airplaneID];
        require(airplane.isActive, "Airplane currently on hold."); 
        Flight storage newFlight = flights[flightCnt];
        newFlight.destination = destination;
        newFlight.airplaneID = airplaneID;
        newFlight.economy = airplane.economy;
        newFlight.firstclass = airplane.firstclass;
        newFlight.departure = departure;
        newFlight.economyPrice = economyPrice * 1000000000000000000;
        newFlight.firstclassPrice = firstclassPrice * 1000000000000000000;
        airplanes[airplaneID].flights.push(flightCnt++);
        emit FlightAnnounced(destination, airplaneID, departure, economyPrice, firstclassPrice);
    }

    function buyTickets(uint flightID, uint economy, uint firstclass) external payable {
        require(flights[flightID].economy >= economy && flights[flightID].firstclass >= firstclass, "Not enough available seats.");
        if(economy + firstclass > 4) {
            revert Max4TicketsError(economy + firstclass);
        }
        address user = msg.sender;
        uint256 price = economy * flights[flightID].economyPrice + firstclass * flights[flightID].firstclassPrice;

        if (MVPWAirlinesToken.allowance(user, address(this)) < price) {
            revert AllowanceError();
        }

        if(flights[flightID].tickets[user].isDone){
            Purchase memory purchase = flights[flightID].tickets[user];
            if(purchase.economy + purchase.firstclass + economy + firstclass > 4){
                revert Max4TicketsError(purchase.economy + purchase.firstclass + economy + firstclass);
            }
            purchase.economy += economy;
            purchase.firstclass += firstclass;
            flights[flightID].tickets[user] = purchase; 
        } else {
            flights[flightID].tickets[user] = Purchase(economy, firstclass, true);
        }

        MVPWAirlinesToken.transferFrom(user, address(this), price);

        flights[flightID].economy -= economy; 
        flights[flightID].firstclass -= firstclass;
        emit TicketsPurchased(flightID, economy, firstclass, price);
    }

    function cancelTickets(uint flightID) external payable {
        address user = msg.sender;
        require(flights[flightID].tickets[user].isDone, "No purchase from this user.");

        Purchase memory purchase = flights[flightID].tickets[user];
        flights[flightID].economy += purchase.economy; 
        flights[flightID].firstclass += purchase.firstclass;
        uint timeSpan = flights[flightID].departure - block.timestamp;

        if(timeSpan > 86400){ 
            uint256 amount = purchase.economy * flights[flightID].economyPrice + purchase.firstclass * flights[flightID].firstclassPrice;
            if(timeSpan <= 172800){
                amount = amount / 5 * 4;
            }
            MVPWAirlinesToken.transfer(user, amount);
        }
       
        delete flights[flightID].tickets[user];
        emit TicketsCanceled(flightID, purchase.economy + purchase.firstclass);
    }
    
}
