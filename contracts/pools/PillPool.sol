// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../Pills.sol";
import "../interfaces/IBlast.sol";
import "../Tracker.sol";
import "./YieldPool.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

///@author k3rn3lpanic
contract PillPool is Ownable, Tracker, ReentrancyGuard {
    Pills public pillToken;
    IERC20 public usdb;
    uint256 public absolutePrize;
    uint256 public poolBalanceFinal;
    uint256 public yieldAmountFinal;
    bool public yieldAvailable = false;
    IERC20Rebasing public blast;
    YieldPool public pool;
    mapping(address => bool) public notFirstTime;
    mapping(address => bool) public yieldClaimed;
    mapping(address => bool) public rewardClaimed;
    mapping(address => uint256) public absolutePrizeInLatestClaim;
    mapping(address => uint256) public amountClaimed;
    mapping(address => uint256) public yieldAmountClaimed;

    event ClaimedRewards(address indexed claimer, uint256 amount, uint256 timestamp);
    event ClaimedYieldRewards(address indexed claimer, uint256 amount, uint256 timestamp);
    event NewIncome(uint256 amount, uint256 timestamp);

    constructor(address _pillToken) {
        pillToken = Pills(payable(_pillToken));
        usdb = IERC20(BLAST_REBASE_ADDRESS);
        blast = IERC20Rebasing(BLAST_REBASE_ADDRESS);
        blast.configure(YieldMode.CLAIMABLE);
        pool = new YieldPool();
    }

    function pillsSetFirstTime(address add) public{
        if (msg.sender != address(pillToken)){
            revert MatrixError("Only pill can call this function");
        }
        if (!notFirstTime[add]){
            absolutePrizeInLatestClaim[add] = absolutePrize;
            notFirstTime[add] = true;
        }
    }

    // This is going to be called by the matrix contract whenever a new income coming towards pool
    function onIncome(uint256 amount) external onlyOwner trackGas {
        absolutePrize += amount;
        poolBalanceFinal += amount;
        emit NewIncome(amount, block.timestamp);
    }

    function claimRewards() public notBanned{
        claimRewardsFor(msg.sender);
    }

    function claimRewardsFor(address claimer) public nonReentrant trackGas notBanned {
        uint256 amount = claimableRewards(claimer);
        if (amount == 0) return;
        amountClaimed[claimer] += amount;
        absolutePrizeInLatestClaim[claimer] = absolutePrize;
        if (!game.isEnded()){
            poolBalanceFinal -= amount;
        }
        if (game.isEnded())
            rewardClaimed[claimer] = true;
            
        usdb.transfer(claimer, amount);
        emit ClaimedRewards(claimer, amount, block.timestamp);
    }

    function claimableRewards(address claimer) public view returns (uint256) {
        if (pillToken.totalSupply() == 0) return 0;
        if (!game.isEnded()){
            // distribute based on the penaly
            return ((absolutePrize - absolutePrizeInLatestClaim[claimer]) * pillToken.totalBalanceOf(address(claimer)))
            / (pillToken.totalSupply() * 2);
        } else{
            if (rewardClaimed[claimer]) return 0;
            // distribute the poolbalance based on the pills amount
            return (poolBalanceFinal * pillToken.totalBalanceOf(address(claimer))) / (pillToken.totalSupply());
        }
    }

    function availableYield() external view returns (uint256) {
        return blast.getClaimableAmount(address(this));
    }

    function claimYield() public trackGas notBanned{
        claimYieldFor(msg.sender);
    }

    function claimYieldFor(address user) public nonReentrant trackGas notBanned{
        if (!game.isEnded()) revert MatrixError("Game not ended");
        if (yieldClaimed[user]) revert MatrixError("Already claimed");
        if (!yieldAvailable){
            yieldAmountFinal = blast.getClaimableAmount(address(this));
            blast.claim(address(pool), yieldAmountFinal);
            yieldAvailable = true;
        }
        uint256 yieldShare = (yieldAmountFinal * pillToken.totalBalanceOf(user)) / pillToken.totalSupply();
        yieldAmountClaimed[user] += yieldShare;
        if (game.isEnded()){
            yieldClaimed[user] = true;
        }
        pool.transferYield(address(user), yieldShare);
    }

    function claimableYieldRewards(address claimer) public view returns (uint256) {
        if (pillToken.totalSupply() == 0) return 0;
        if (game.isEnded()){
            if (yieldClaimed[claimer]){
                return 0;
            }
        }
        return (
            (blast.getClaimableAmount(address(this)))
                * pillToken.totalBalanceOf(claimer)
        ) / pillToken.totalSupply();
    }

    function emergencyWithdraw(address withdrawalWallet) external onlyOwner {
        usdb.transfer(withdrawalWallet, usdb.balanceOf(address(this)));
    }
}
