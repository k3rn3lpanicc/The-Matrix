// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract USDB is ERC20 {
    constructor(uint256 amount) ERC20("USD BLAST", "USDB") {
        _mint(msg.sender, amount * 10 ** 18);
    }

    function mint(address user, uint256 amount) public {
        _mint(user, amount * 10 ** 18);
    }
}
