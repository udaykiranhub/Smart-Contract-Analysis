// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/Counters.sol";

contract FlightBooking {
    using Counters for Counters.Counter;
    Counters.Counter private _totalFlights;

    struct FlightStruct {
        uint id;
        string flightNumber;
        string departure;
        string arrival;
        string date;
        uint totalSeats;
        uint pricePerSeat;
        uint availableSeats;
        address airline;
        bool isActive;
        bool isDeleted;
        uint timestamp;
    }

    struct BookingStruct {
        uint id;
        address passenger;
        uint seatCount;
        uint totalPrice;
        bool checkedIn;
        bool cancelled;
        uint bookingDate;
    }

    struct ReviewStruct {
        uint id;
        uint flightId;
        string reviewText;
        uint timestamp;
        address owner;
    }

    event SecurityFeeUpdated(uint newFee);

    uint public securityFee;
    uint public taxPercent;

    mapping(uint => FlightStruct) flights;
    mapping(uint => BookingStruct[]) bookingsOf;
    mapping(uint => ReviewStruct[]) reviewsOf;
    mapping(uint => bool) flightExist;
    mapping(address => mapping(uint => bool)) hasBooked;

    constructor(uint _taxPercent, uint _securityFee) {
        taxPercent = _taxPercent;
        securityFee = _securityFee;
    }

    function createFlight(
        string memory flightNumber,
        string memory departure,
        string memory arrival,
        string memory date,
        uint totalSeats,
        uint pricePerSeat
    ) public {
        require(bytes(flightNumber).length > 0, "Flight Number cannot be empty");
        require(bytes(departure).length > 0, "Departure cannot be empty");
        require(bytes(arrival).length > 0, "Arrival cannot be empty");
        require(bytes(date).length > 0, "Date cannot be empty");
        require(totalSeats > 0, "Seats cannot be zero");
        require(pricePerSeat > 0 ether, "Price cannot be zero");

        _totalFlights.increment();
        FlightStruct memory flight;
        flight.id = _totalFlights.current();
        flight.flightNumber = flightNumber;
        flight.departure = departure;
        flight.arrival = arrival;
        flight.date = date;
        flight.totalSeats = totalSeats;
        flight.availableSeats = totalSeats;
        flight.pricePerSeat = pricePerSeat;
        flight.airline = msg.sender;
        flight.isActive = true;
        flight.timestamp = block.timestamp;

        flightExist[flight.id] = true;
        flights[_totalFlights.current()] = flight;
    }

    function checkInFlight(uint id, uint bookingId) public {
        require(msg.sender == bookingsOf[id][bookingId].passenger, "Unauthorized passenger");
        require(!bookingsOf[id][bookingId].checkedIn, "Already checked-in");

        bookingsOf[id][bookingId].checkedIn = true;
        uint price = bookingsOf[id][bookingId].totalPrice;
        uint fee = (price * taxPercent) / 100;

        payTo(flights[id].airline, (price - fee));
        payTo(msg.sender, securityFee);
    }

    function refundBooking(uint id, uint bookingId) public {
        require(!bookingsOf[id][bookingId].checkedIn, "Already checked-in");
        require(msg.sender == bookingsOf[id][bookingId].passenger, "Unauthorized passenger");

        bookingsOf[id][bookingId].cancelled = true;
        flights[id].availableSeats += bookingsOf[id][bookingId].seatCount;

        uint refundAmount = bookingsOf[id][bookingId].totalPrice - securityFee;
        payTo(msg.sender, refundAmount);
    }

    function payTo(address to, uint256 amount) internal {
        (bool success, ) = payable(to).call{value: amount}("");
        require(success);
    }
}
