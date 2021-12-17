// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract NFTicket is ERC721, Pausable, Ownable {
    constructor(
        string memory _eventName,
        string memory _eventSymbol
    ) ERC721(_eventName, _eventSymbol) {}

    function createTicket(uint256 tokenId, address to) external onlyOwner {
        _mint(to, tokenId);
    }
}