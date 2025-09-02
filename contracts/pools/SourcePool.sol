// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../interfaces/IBlast.sol";
import "../Tracker.sol";
import "../StSource.sol";
import "../Source.sol";
import "./YieldPool.sol";

// NOTE: Don't forget to transfer ownership of this contract to Matrix contract
///@author k3rn3lpanic
contract SourcePool is Ownable, Tracker {
    // The Source token that people holde
    YieldPool public pool;
    Source public sourceToken;
    IERC20 public usdb; // usdb
    uint256 public absolutePrize;
    uint256 public poolBalance;
    uint256 public poolBalanceFinal;
    uint256 public totalStaked;
    uint256 public totalStakedFinal;
    uint256 public yieldAmountFinal;
    bool public yieldAvailable = false;
    StSource public stSourceToken;
    mapping(address => uint256) public absolutePrizeInLatestClaim;
    mapping(address => uint256) public amountStaked;
    mapping(address => uint256) public amountStakedFinal;
    mapping(address => bool) public yieldClaimed;
    mapping(address => bool) public rewardClaimed;
    mapping(address => uint256) public amountClaimed;
    mapping(address => uint256) public yieldAmountClaimed;
    IERC20Rebasing public blast;

    event ClaimedRewards(address indexed claimer, uint256 amount, uint256 timestamp);
    event ClaimedYieldRewards(address indexed claimer, uint256 amount, uint256 timestamp);
    event NewIncome(uint256 amount, uint256 timestamp);
    event Staked(address indexed staker, uint256 amount, uint256 timestamp);
    event UnStaked(address indexed staker, uint256 amount, uint256 timestamp);

    constructor(address _sourceToken) {
        usdb = IERC20(BLAST_REBASE_ADDRESS);
        blast = IERC20Rebasing(BLAST_REBASE_ADDRESS);
        blast.configure(YieldMode.CLAIMABLE);
        pool = new YieldPool();
        sourceToken = Source(_sourceToken);
        stSourceToken = new StSource();
    }

    function stake(uint256 amount) external trackGas notBanned{
        if (game.isEnded()) revert MatrixError("Game has ended");
        if (amount == 0) revert("Invalid amount");
        if (amount > sourceToken.balanceOf(msg.sender)) {
            revert MatrixError("Insufficient balance");
        }
        if (sourceToken.allowance(msg.sender, address(this)) < amount) {
            revert MatrixError("Not enough allowance");
        }
        if (amountStaked[msg.sender] != 0){
            // first time staking, no need to claim rewards!
            claimRewards();
        }
        amountStaked[msg.sender] += amount;
        amountStakedFinal[msg.sender] += amount;
        totalStaked += amount;
        totalStakedFinal += amount;
        absolutePrizeInLatestClaim[msg.sender] = absolutePrize;
        sourceToken.transferFrom(msg.sender, address(this), amount);
        stSourceToken.mint(msg.sender, amount);
        emit Staked(msg.sender, amount, block.timestamp);
    }

    function unstake(uint256 amount) external trackGas {
        if (amount == 0) revert MatrixError("Invalid amount");
        if (amount > amountStaked[msg.sender]) {
            revert MatrixError("Insufficient amount");
        }
        if (stSourceToken.balanceOf(msg.sender) < amount) {
            revert MatrixError("Insufficient balance");
        }
        if (stSourceToken.allowance(msg.sender, address(this)) < amount) {
            revert MatrixError("Not enough allowance");
        }
        claimRewards();
        absolutePrizeInLatestClaim[msg.sender] = absolutePrize;
        amountStaked[msg.sender] -= amount;
        if (!game.isEnded()){
            amountStakedFinal[msg.sender] -= amount;
            totalStakedFinal -= amount;
        }
        totalStaked -= amount;
        stSourceToken.burn(msg.sender, amount);
        sourceToken.transfer(msg.sender, amount);
        emit UnStaked(msg.sender, amount, block.timestamp);
    }

    // This is going to be called by the matrix contract whenever a new income coming towards pool
    function onIncome(uint256 amount) external onlyOwner trackGas {
        absolutePrize += amount;
        poolBalance += amount;
        poolBalanceFinal += amount;
        emit NewIncome(amount, block.timestamp);
    }

    function claimRewards() public notBanned{
        claimRewardsFor(msg.sender);
    }

    function claimRewardsFor(address claimer) public trackGas notBanned {
        uint256 amount = claimableRewards(claimer); 
        // if amount is zero, do not update the latest claim prize, or do anything
        if (amount == 0) return; 
        absolutePrizeInLatestClaim[claimer] = absolutePrize; 
        poolBalance -= amount; 
        if (!game.isEnded()){
            poolBalanceFinal -= amount;
        }
        amountClaimed[claimer] += amount;
        if (game.isEnded()){
            rewardClaimed[claimer] = true;
        }
        
        usdb.transfer(claimer, amount);
        emit ClaimedRewards(claimer, amount, block.timestamp);
    }

    function claimableRewards(address claimer) public view returns (uint256) {
        if (!game.isEnded()){
            if (amountStaked[claimer] == 0) return 0;
            if (totalStaked == 0) return 0;
            // Penalty (half amount)
            return ((absolutePrize - absolutePrizeInLatestClaim[claimer]) * amountStaked[claimer]) / (totalStaked * 2);
        } else {
            if (amountStakedFinal[claimer] == 0) return 0;
            if (totalStakedFinal == 0) return 0;
            if (rewardClaimed[claimer]) return 0;
            return (poolBalanceFinal * amountStakedFinal[claimer]) / totalStakedFinal;
        }
    }

    function availableYield() external view returns (uint256) {
        return blast.getClaimableAmount(address(this));
    }

    function claimYield() private trackGas {
        claimYieldFor(msg.sender);
    }

    function claimYieldFor(address user) public trackGas notBanned{
        if (!game.isEnded()) revert MatrixError("Game not ended");
        if (yieldClaimed[user]) revert MatrixError("Already claimed");
        if (!yieldAvailable){
            yieldAmountFinal = blast.getClaimableAmount(address(this));
            blast.claim(address(pool), yieldAmountFinal);
            yieldAvailable = true;
        }
        uint256 yieldShare = (yieldAmountFinal * amountStakedFinal[user]) / totalStakedFinal;
        yieldAmountClaimed[user] += yieldShare;
        if (game.isEnded()){
            yieldClaimed[user] = true;
        }
        pool.transferYield(address(user), yieldShare);
    }

    function claimableYieldRewards(address claimer) external view returns (uint256) {
        if (totalStaked == 0) return 0;
        if (game.isEnded()){
            if (yieldClaimed[claimer]){
                return 0;
            }
        }
        return (
            (blast.getClaimableAmount(address(this)))
                * amountStakedFinal[claimer]
        ) / totalStakedFinal;
    }

    function emergencyWithdraw(address withdrawalWallet) external onlyOwner {
        usdb.transfer(withdrawalWallet, usdb.balanceOf(address(this)));
    }
}
