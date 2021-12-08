// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";


/*
This ECR20 token:

- adds a cap to the supply of tokens

- ability for holders to burn (destroy) their tokens

- a minter role that allows for token minting (creation)

- a pauser role that allows to stop all token transfers

This contract uses AccessControl to lock permissioned functions 
using the different roles - head to its documentation for details.

The account that deploys the contract will be granted the minter and pauser roles, 
as well as the default admin role, which will let it grant both minter and pauser roles 
to other accounts.
*/

contract MyToken is ERC20, ERC20Capped, ERC20PresetMinterPauser {
    
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply
    ) 
        ERC20Capped(initialSupply * 2)
        ERC20PresetMinterPauser("StarDucks Capu-Token", "SCT")
    {
        
    _mint(msg.sender, initialSupply);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20PresetMinterPauser) {
        super._beforeTokenTransfer(from, to, amount);
    }


    function _mint(
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Capped) {
        super._mint(to, amount);
    }
}
