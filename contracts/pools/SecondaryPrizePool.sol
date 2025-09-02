// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Tracker.sol";
import "../interfaces/IBlast.sol";

///@author k3rn3lpanic
contract SecondaryPrizePool is Ownable, Tracker {
    IERC20 public USDBToken;

    event TransferedOut(address to, uint256 amount, uint256 timestamp);

    constructor() {
        USDBToken = IERC20(BLAST_REBASE_ADDRESS);
    }

    function distribute(address[3] calldata winners, uint256[3] calldata nftamounts) external onlyOwner trackGas {
        uint256 sum = 0;
        uint256 t = 0;
        for (uint256 i = 0; i < 3; i++) {
            if (nftamounts[i] > 0){
                t = i;
                sum += nftamounts[i];
            }
        }
        uint256 prizeAmount = USDBToken.balanceOf(address(this));
        for (uint256 i = 0; i <= t; i++) {
            emit TransferedOut(winners[i], (nftamounts[i] * prizeAmount) / sum, block.timestamp);
            USDBToken.transfer(winners[i], (nftamounts[i] * prizeAmount) / sum);
        }
    }
}
