// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../interfaces/IBlast.sol";

contract YieldPool is Ownable {
    IERC20 public USDBToken;

    constructor() Ownable(msg.sender){
        USDBToken = IERC20(BLAST_REBASE_ADDRESS);
    }

    function transferYield(address to, uint256 amount) external {
        USDBToken.transfer(to, amount);
    }
}
