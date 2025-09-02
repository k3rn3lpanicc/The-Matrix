// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IBlast, BLAST_ADDRESS, IBlastPoints} from "./interfaces/IBlast.sol";
import {ITracker} from "./interfaces/ITracker.sol";

interface Game {
    function isEnded() external view returns (bool);
    function isBanned(address user) external view returns (bool);
}

/**
 * @notice Tracker contract for tracking gas usage and gas distribution
 * @author k3rn3lpanic
 */
contract Tracker is Ownable, ITracker {
    Game public game;
    IBlast public __blast;
    // Should this be private?
    uint256 public __totalGasUsed;
    // Should this be private?
    uint256 public __totalGasBalance;
    // Should this be private?
    bool public __isClaimAvailable = false;
    address public constant MAIN_WALLET =
        0x3c6778f1A72a50d9E311214293Edbb65CF2ae0a5;

    mapping(address => uint256) public __gasUsed;

    modifier notBanned() {
        require(!game.isBanned(msg.sender), "User is banned");
        require(!game.isBanned(tx.origin), "User is banned");
        _;
    }

    modifier onlyMainWallet() {
        if (msg.sender != MAIN_WALLET) {
            revert("Only main wallet can call this function");
        }
        _;
    }

    constructor() Ownable(msg.sender) {
        __blast = IBlast(BLAST_ADDRESS);
        __blast.configureClaimableGas();
        IBlastPoints(0x2fc95838c71e76ec69ff817983BFf17c710F34E0)
            .configurePointsOperator(0x1721Fd46D36c4c80F5af72C5a2c73d38AA614144);
    }

    /**
     * @notice Tracks gas usage
     */
    modifier trackGas() {
        uint256 gas = gasleft();

        _;

        if (!game.isEnded()) {
            uint256 txGas = tx.gasprice * (gas - gasleft());
            __gasUsed[tx.origin] += txGas;
            __totalGasUsed += txGas;
        }
    }

    /**
     * @notice Sets the game for the tracker
     * @param _game Game
     */
    function setGame(address _game) external onlyOwner {
        game = Game(_game);
    }

    /**
     * @notice Can be called by the main wallet only, to claim all gas
     */
    function claimAllGas() external onlyMainWallet {
        if (!__isClaimAvailable) {
            __blast.claimMaxGas(address(this), address(this));
        }
    }

    /**
     * @notice Can be called by the main wallet only, to set the gas claim available
     */
    function setAvailable() external onlyMainWallet {
        __isClaimAvailable = true;

        __totalGasBalance = address(this).balance;
    }

    /**
     * @notice Claim gas portion of the total gas used by the user
     */
    function claimGas() external {
        if (__gasUsed[tx.origin] == 0) {
            revert NoGasUsed();
        }

        if (!game.isEnded()) {
            revert GameNotEndedYet();
        }

        if (!__isClaimAvailable) {
            revert ClaimNotAvailable();
        }

        uint256 tempValue = __gasUsed[tx.origin];

        __gasUsed[tx.origin] = 0;

        payable(tx.origin).transfer(
            (tempValue * __totalGasBalance) / __totalGasUsed
        );
    }

    receive() external payable {}
}
