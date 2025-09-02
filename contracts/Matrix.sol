/*

Welcome to the
 __       __              __                __           
/  \     /  |            /  |              /  |          
$$  \   /$$ |  ______   _$$ |_     ______  $$/  __    __ 
$$$  \ /$$$ | /      \ / $$   |   /      \ /  |/  \  /  |
$$$$  /$$$$ | $$$$$$  |$$$$$$/   /$$$$$$  |$$ |$$  \/$$/ 
$$ $$ $$/$$ | /    $$ |  $$ | __ $$ |  $$/ $$ | $$  $$<  
$$ |$$$/ $$ |/$$$$$$$ |  $$ |/  |$$ |      $$ | /$$$$  \ 
$$ | $/  $$ |$$    $$ |  $$  $$/ $$ |      $$ |/$$/ $$  |
$$/      $$/  $$$$$$$/    $$$$/  $$/       $$/ $$/   $$/ 
                                                         
                                                         
                                                         
                                                                                                                                                 
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Pills.sol";
import "./pools/PillPool.sol";
import "./pools/PrizePool.sol";
import "./pools/SourcePool.sol";
import "./Tracker.sol";
import "./pools/SecondaryPrizePool.sol";
import "./interfaces/IBlast.sol";

///@author k3rn3lpanic
// Note: Don't forget to set next round pool prize before ending the game
contract Matrix is Tracker, Game {
    // ________________________GAME INFO________________
    mapping(address referee => address referer) public referralMap;
    mapping(address referer => uint256 referedAmount) public referralCount;
    mapping(address referer => uint256 earned) public refererEarned;
    mapping(address purchaser => bool isBanned) public bannedList;
    uint256 public timeDifferenceInPause;
    uint256 public timeCap = 1 days;
    uint256 public endTime;
    uint256 public priceThreshold;
    address public latestPurchaser;
    address public deuxWallet;
    address public nextRoundPrizePool;
    address[3] public topThreePlayers;
    uint256[3] public topThreePlayerPills;
    bool public gameEnded = false;
    bool public started = false;
    uint256 public basePrize = 407;
    // ________________________GAME INFO________________

    // ______________TOKENS_____________________________
    IERC20 public paymentToken; // -> USDB
    Pills public pillsToken; // -> Pills ERC1155
    // ______________TOKENS_____________________________

    // ______________POOLS______________________________
    PrizePool public prizePool;
    SourcePool public matrixSourcePool;
    PillPool public pillPool;
    SecondaryPrizePool public secondaryPrizePool;
    // ______________POOLS______________________________

    uint256 public round = 1;

    // _____________EVENTS_____________________________
    event Refered(address referee, address referer, uint256 timestamp);
    event PurchasedPill(
        address purchaser,
        PillType pillType,
        uint256 amount,
        uint256 timestamp
    );
    event TopThreePlayerChanged(
        address[3] topThreePlayers,
        uint256[3] topThreePlayerPills,
        uint256 timestamp
    );
    event InjectedPrize(uint256 amount, uint256 timestamp);
    event GameEnded(uint256 timestamp);
    // _____________EVENTS_____________________________

    enum PillType {
        RED,
        BLUE
    }

    modifier gameNotEnded() {
        require(block.timestamp < endTime, "Game ended");
        _;
    }

    modifier gameStarted() {
        require(endTime != 0, "Game not started");
        require(started, "Game not started");
        _;
    }

    constructor(
        address _prizePool,
        address _sourcePool,
        address _pillsToken,
        address _pillPool,
        uint256 _pillPriceThreshold,
        address _secondaryPrizePool,
        address _deuxWallet
    ) {
        paymentToken = IERC20(BLAST_REBASE_ADDRESS);
        pillsToken = Pills(payable(_pillsToken));
        prizePool = PrizePool(payable(_prizePool));
        matrixSourcePool = SourcePool(payable(_sourcePool));
        pillPool = PillPool(payable(_pillPool));
        secondaryPrizePool = SecondaryPrizePool(payable(_secondaryPrizePool));
        deuxWallet = _deuxWallet;
        priceThreshold = _pillPriceThreshold;
        endTime = 0; 
    }

    function setReferer(address _referer) external trackGas notBanned {
        if (!started) revert MatrixError("Game not started");
        if (referralMap[msg.sender] != address(0)) revert MatrixError("Already refered");
        if (_referer == address(0)) revert MatrixError("Invalid referer");
        if (msg.sender == _referer) revert MatrixError("Invalid referer");
        if (referralMap[msg.sender] != address(0)) {
            revert MatrixError("Referer already set");
        }
        referralMap[msg.sender] = _referer;
        referralCount[_referer] += 1;
        emit Refered(msg.sender, _referer, block.timestamp);
    }

    function setNextRoundPrizePool(
        address _nextRoundPrizePool
    ) external onlyOwner trackGas {
        nextRoundPrizePool = _nextRoundPrizePool;
    }

    function minAmount(uint256 amount1, uint256 amount2) private pure returns(uint256) {
        return amount1 < amount2 ? amount1 : amount2;
    }

    function setDeuxWallet(address _deuxWallet) external onlyOwner trackGas {
        deuxWallet = _deuxWallet;
    }

    function setPillPriceThreshold(uint256 _pillPriceThreshold) external onlyOwner{
        priceThreshold = _pillPriceThreshold;
    }

    function startGame(uint256 timeToExtend) external onlyOwner {
        started = true;
        endTime = block.timestamp + timeToExtend; // This one is the real end time of the game since it sets the started to true (other functions rely on that to work)
    }

    function reduceEndTime(uint256 timeToReduce) external onlyOwner{
        endTime -= timeToReduce;
    }

    function pauseGame() external onlyOwner {
        started = false;
        timeDifferenceInPause = endTime - block.timestamp;
        endTime = 0;
    }

    function resumeGame() external onlyOwner {
        started = true;
        endTime = block.timestamp + timeDifferenceInPause;
        timeDifferenceInPause = 0;
    }

    function setTimeCap(uint256 cap) external onlyOwner{
        timeCap = cap;
    }

    function getPillPrice() public view returns (uint256) {
        return minAmount(paymentToken.balanceOf(address(prizePool)) / (basePrize), priceThreshold);
    }

    function getTimeDelta() public view returns (uint256) {
        uint256 prizePoolAmount = paymentToken.balanceOf(address(prizePool));
        uint256 result = 0;
        if (
            prizePoolAmount >= basePrize * 1e18 &&
            prizePoolAmount <= basePrize * 20 * 1e18
        ) result = 30 seconds;
        else if (
            prizePoolAmount >= basePrize * 20 * 1e18 &&
            prizePoolAmount <= basePrize * 50 * 1e18
        ) result = 15 seconds;
        else if (
            prizePoolAmount >= basePrize * 50 * 1e18 &&
            prizePoolAmount <= basePrize * 100 * 1e18
        ) result = 7 seconds;
        else if (prizePoolAmount >= basePrize * 100 * 1e18) result = 5 seconds;
        // To ensure the endTime is at most 1day away from us
        if (result + endTime > block.timestamp + timeCap) {
            if (block.timestamp + timeCap < endTime){
                return 0;
            }
            return (block.timestamp + timeCap) - endTime;
        }
        return result;
    }

    function purchasePill(
        PillType _type,
        uint256 amount
    ) external trackGas gameStarted gameNotEnded notBanned {
        if (amount <= 0) revert MatrixError("Invalid amount");
        uint256 price = getPillPrice();
        if (
            paymentToken.allowance(msg.sender, address(this)) < price * amount
        ) {
            revert MatrixError("Not enough allowance");
        }
        uint256 _amount = price * amount;
        if (referralMap[msg.sender] != address(0)) {
            uint256 refererShare = _amount / 10;
            address referer = referralMap[msg.sender];
            paymentToken.transferFrom(
                msg.sender,
                referer,
                refererShare
            );
            refererEarned[referer] += refererShare;
            _amount -= refererShare;
        }

        // The first half goes to the prize pool
        paymentToken.transferFrom(msg.sender, address(prizePool), _amount / 2);

        // 10% goes to Dues Ex Machina
        paymentToken.transferFrom(msg.sender, deuxWallet, _amount / 10);
        if (_type == PillType.RED) {
            paymentToken.transferFrom(
                msg.sender,
                address(pillPool),
                _amount / 4
            ); // 25% -> Pill Pool
            pillPool.onIncome(_amount / 4); // Inform the pill pool
            paymentToken.transferFrom(
                msg.sender,
                address(matrixSourcePool),
                (_amount * 3) / 20
            ); // 15% -> Source Pool
            matrixSourcePool.onIncome((_amount * 3) / 20); // Inform the source pool
            pillsToken.mintRedPill(msg.sender, amount); // Mint the pills
        } else if (_type == PillType.BLUE) {
            paymentToken.transferFrom(
                msg.sender,
                address(pillPool),
                (_amount * 3) / 20
            ); // 15% -> Pill Pool
            pillPool.onIncome((_amount * 3) / 20); // Inform the pill pool
            paymentToken.transferFrom(
                msg.sender,
                address(matrixSourcePool),
                _amount / 4
            ); // 25% -> Source Pool
            matrixSourcePool.onIncome(_amount / 4); // Inform the source pool
            pillsToken.mintBluePill(msg.sender, amount); // Mint the pills
        }
        latestPurchaser = msg.sender;
        uint256 dt = getTimeDelta();
        endTime += dt;
        // if not in the top3 list
        if (latestPurchaser != topThreePlayers[0] && latestPurchaser != topThreePlayers[1] && latestPurchaser != topThreePlayers[2]) {    
            // if bigger than the best
            if (
                pillsToken.totalBalanceOf(latestPurchaser) >= topThreePlayerPills[0]
            ) {
                topThreePlayerPills[2] = topThreePlayerPills[1];
                topThreePlayers[2] = topThreePlayers[1];
                topThreePlayerPills[1] = topThreePlayerPills[0];
                topThreePlayers[1] = topThreePlayers[0];
                topThreePlayerPills[0] = pillsToken.totalBalanceOf(latestPurchaser);
                topThreePlayers[0] = latestPurchaser;
                emit TopThreePlayerChanged(
                    topThreePlayers,
                    topThreePlayerPills,
                    block.timestamp
                );
            } else if (
                pillsToken.totalBalanceOf(latestPurchaser) >=
                topThreePlayerPills[1] &&
                pillsToken.totalBalanceOf(latestPurchaser) < topThreePlayerPills[0]
            ) {
                // if bigger than the second best
                topThreePlayerPills[2] = topThreePlayerPills[1];
                topThreePlayers[2] = topThreePlayers[1];
                topThreePlayerPills[1] = pillsToken.totalBalanceOf(latestPurchaser);
                topThreePlayers[1] = latestPurchaser;
                emit TopThreePlayerChanged(
                    topThreePlayers,
                    topThreePlayerPills,
                    block.timestamp
                );
            } else if (
                pillsToken.totalBalanceOf(latestPurchaser) >=
                topThreePlayerPills[2] &&
                pillsToken.totalBalanceOf(latestPurchaser) < topThreePlayerPills[1]
            ) {
                // if bigger than the third best
                topThreePlayers[2] = latestPurchaser;
                topThreePlayerPills[2] = pillsToken.totalBalanceOf(latestPurchaser);
                emit TopThreePlayerChanged(
                    topThreePlayers,
                    topThreePlayerPills,
                    block.timestamp
                );
            }
        } else {
            // if in the list
            if (latestPurchaser == topThreePlayers[0]) {
                // if the best is the same
                topThreePlayerPills[0] = pillsToken.totalBalanceOf(latestPurchaser); // just update the amount
            } else if (latestPurchaser == topThreePlayers[1]) {
                // if the second best is the same
                topThreePlayerPills[1] = pillsToken.totalBalanceOf(latestPurchaser); //update the amount
                if (topThreePlayerPills[0] < topThreePlayerPills[1]) {
                    // if the second best gets bigger than the best
                    topThreePlayers[1] = topThreePlayers[0];
                    topThreePlayerPills[1] = topThreePlayerPills[0];
                    topThreePlayers[0] = latestPurchaser;
                    topThreePlayerPills[0] = pillsToken.totalBalanceOf(latestPurchaser);
                }
            } else if (latestPurchaser == topThreePlayers[2]) {
                // if the third best is the same
                topThreePlayerPills[2] = pillsToken.totalBalanceOf(latestPurchaser); //update the amount
                if (
                    topThreePlayerPills[2] > topThreePlayerPills[0]
                ){
                    // if it gets bigger than the best
                    topThreePlayers[2] = topThreePlayers[1];
                    topThreePlayerPills[2] = topThreePlayerPills[1];
                    topThreePlayers[1] = topThreePlayers[0];
                    topThreePlayerPills[1] = topThreePlayerPills[0];
                    topThreePlayers[0] = latestPurchaser;
                    topThreePlayerPills[0] = pillsToken.totalBalanceOf(latestPurchaser);

                } else if (
                    topThreePlayerPills[2] > topThreePlayerPills[1]
                ){
                    // if it gets bigger than the second best (but not bigger than the best)
                    topThreePlayers[2] = topThreePlayers[1];
                    topThreePlayerPills[2] = topThreePlayerPills[1];
                    topThreePlayers[1] = latestPurchaser;
                    topThreePlayerPills[1] = pillsToken.totalBalanceOf(latestPurchaser);
                }
            }
        }
        emit PurchasedPill(latestPurchaser, _type, amount, block.timestamp);
    }


    function endGame() external trackGas gameStarted notBanned {
        if (nextRoundPrizePool == address(0)) {
            revert MatrixError("No next round");
        }
        if (block.timestamp <= endTime) revert MatrixError("Not yet");
        if (latestPurchaser == address(0)) {
            // Important: make sure at least one purchase is available in game time
            revert MatrixError("No player");
        } else {
            gameEnded = true;
            // Transfer the winner's share
            uint256 prizePoolAmount = paymentToken.balanceOf(
                address(prizePool)
            );
            prizePool.claimYield();
            prizePool.transferFromPool(
                latestPurchaser,
                (prizePoolAmount * 8) / 10
            ); // 80%
            // Transfer team wallet's share
            // Team wallet transfers
            prizePool.transferFromPool(0xf977A77A09A64B6B95a6Dd2472C004F02f270115, prizePoolAmount / 20); // 5%
            prizePool.transferFromPool(0x1B30f4a5ea4e8D0195747f6e915497b1dD8b8bCB, prizePoolAmount / 20); // 5%
            // Transfer 10% to next round prize pool
            prizePool.transferFromPool(
                nextRoundPrizePool,
                prizePoolAmount / 10
            ); // 10%
            secondaryPrizePool.distribute(topThreePlayers, topThreePlayerPills);
        }
        emit GameEnded(block.timestamp);
    }

    function isEnded() external view returns (bool) {
        return gameEnded;
    }

    function banUser(address user) public onlyOwner{
        bannedList[user] = true;
    }

    function unbanUser(address user) public onlyOwner{
        bannedList[user] = false;
    }

    function isBanned(address user) external view returns (bool) {
        return bannedList[user];
    }

    function emergencyWithdraw(address withdrawalWallet) external onlyOwner {
        prizePool.transferFromPool(withdrawalWallet, paymentToken.balanceOf(address(prizePool)));
    }

    function sourcePoolEmergencyWithdraw(address withdrawalWallet) external onlyOwner {
        matrixSourcePool.emergencyWithdraw(withdrawalWallet);
    }

    function pillPoolEmergencyWithdraw(address withdrawalWallet) external onlyOwner {
        pillPool.emergencyWithdraw(withdrawalWallet);
    }

    function setBasePrize(uint256 _basePrize) external onlyOwner {
        basePrize = _basePrize;
    }

    function endRound() external onlyOwner {
        if (block.timestamp <= endTime) revert MatrixError("Not yet");
        if (latestPurchaser == address(0)) {
            revert MatrixError("No player");
        } else {
            // Transfer the winner's share
            uint256 prizePoolAmount = paymentToken.balanceOf(
                address(prizePool)
            );
            prizePool.claimYield();
            prizePool.transferFromPool(
                latestPurchaser,
                (prizePoolAmount * 8) / 10
            ); // 80%
            prizePool.transferFromPool(0xf977A77A09A64B6B95a6Dd2472C004F02f270115, prizePoolAmount / 20); // 5%
            prizePool.transferFromPool(0x1B30f4a5ea4e8D0195747f6e915497b1dD8b8bCB, prizePoolAmount / 20); // 5%
            secondaryPrizePool.distribute(topThreePlayers, topThreePlayerPills);
        }
        endTime = block.timestamp + 1 days;
        round += 1;
        basePrize = paymentToken.balanceOf(address(prizePool)) / 1e18;
        emit GameEnded(block.timestamp);
    }
}
