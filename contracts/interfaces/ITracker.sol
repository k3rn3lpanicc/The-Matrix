// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @notice Tracker
 * @author k3rn3lpanic
 */
interface ITracker {
    /**
     * @notice Thrown when no gas used by the user and user attemps to claim the gas
     */
    error NoGasUsed();

    /**
     * @notice Thrown when the game has not ended yet
     */
    error GameNotEndedYet();

    /**
     * @notice Thrown when the gas is not available to claim
     */
    error ClaimNotAvailable();

    /**
     * @notice Thrown when something goes wrong in the Matrix
     */
    error MatrixError(string message);
}
