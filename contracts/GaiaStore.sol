// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract GaiaStore is Ownable, Pausable {
    using SafeMath for uint256;
    using Strings for uint256;

    enum EventStatus {
        Created,
        SalesStarted,
        SalesSuspended,
        SalesFinished,
        Completed,
        Settled,
        Cancelled
    }

    struct Event {
        uint256 eventId;
        uint256 startDate;
        uint256 ticketPrice;
        EventStatus status;
    }

    mapping(uint256 => Event) public events;
    mapping(uint256 => uint256[]) public eventTickets;
    
    mapping(address => bool) public whitelist;

    address public NFTICKET_ADDRESS;

    constructor(address _nfticket, address[] memory _whitelist) {
        for(uint i = 0; i < _whitelist.length; i += 1) {
            whitelist[_whitelist[i]] = true;
        }
        NFTICKET_ADDRESS = _nfticket;
    }

    modifier EventNotStarted(uint256 _eventId) {
        require(
            (uint64(block.timestamp) < events[_eventId].startDate),
            "event has already started"
        );
        _;
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "user not allowed");
        _;
    }

    function createEvent(
        uint256 _eventId,
        uint256 _startDate,
        uint256 _ticketPrice,
        uint256[] calldata _tickets
    ) external whenNotPaused {
        events[_eventId] = Event({
            eventId: _eventId,
            startDate: _startDate,
            ticketPrice: _ticketPrice,
            status: EventStatus.Created
        });
        for(uint i = 0; i < _tickets.length; i += 1) {
            uint256 _ticketId = _tickets[i];
            eventTickets[_eventId].push(_ticketId);
        }
    }

    function buyTicket(uint256 _eventId) external payable onlyWhitelisted whenNotPaused {
        uint256 _ticketsAmount = eventTickets[_eventId].length;
        require(_ticketsAmount > 0, "not enough tickets");
        
        uint256 _ticketPrice = events[_eventId].ticketPrice;
        require(msg.value >= _ticketPrice, "not enough money");

        payable(msg.sender).transfer(msg.value.sub(_ticketPrice));
        uint256 _ticketId = eventTickets[_eventId][_ticketsAmount.sub(1)];

        IERC721 nft = IERC721(NFTICKET_ADDRESS);
        nft.transferFrom(address(this), msg.sender, _ticketId);
        eventTickets[_eventId].pop();
    }
}