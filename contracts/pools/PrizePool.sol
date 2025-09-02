// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IBlast.sol";
import "../Tracker.sol";

///@author k3rn3lpanic
contract PrizePool is Ownable, Tracker {
    address public secondaryPrizePool;
    IERC20 public USDBToken;
    IERC20Rebasing public blast;

    event ClaimedYield(uint256 amount, uint256 timestamp);
    event TransferedOut(address to, uint256 amount, uint256 timestamp);

    constructor(address _secondaryPrizePool) {
        USDBToken = IERC20(BLAST_REBASE_ADDRESS);
        blast = IERC20Rebasing(BLAST_REBASE_ADDRESS);
        blast.configure(YieldMode.CLAIMABLE);
        secondaryPrizePool = _secondaryPrizePool; 
    }

    // The Matrix can transfer USDB tokens out of the pool
    function transferFromPool(address to, uint256 amount) external onlyOwner trackGas {
        USDBToken.transfer(to, amount);
        emit TransferedOut(to, amount, block.timestamp);
    }

    // The Matrix can claim yield to the secondary pool
    function claimYield() external onlyOwner trackGas {
        uint256 claimableAmount = blast.getClaimableAmount(address(this));
        emit ClaimedYield(claimableAmount, block.timestamp);
        blast.claim(secondaryPrizePool, claimableAmount);
    }
}
