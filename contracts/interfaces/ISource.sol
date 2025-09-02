// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @notice Source token
 * @author k3rn3lpanic
 */
interface ISource {
    /**
     * @notice Thrown when no ETH is staked in the source airdrop
     */
    error NoETHStaked();

    /**
     * @notice Thrown when the distribution is called more than once
     */
    error SourceNotMintable();

    /**
     * @notice Thrown when no presale token to withdraw is available
     */
    error NoPresaleTokenToWithdraw();

    /**
     * @notice Thrown when the ETH stake duration has ended
     */
    error StakeDurationEnded();

    /**
     * @notice Emitted when user claims portions of presale Source tokens
     * @param _user The user address who claimed the presale Source tokens
     * @param _amount The amount of Source tokens claimed
     * @param _remaining The remaining Source tokens to claim
     * @param _timestamp The timestamp when the Source tokens were claimed
     */
    event PresaleClaimed(address _user, uint256 _amount, uint256 _remaining, uint256 _timestamp);

    /**
     * @notice Emitted when the user staked ETH in Source contract for airdrop
     * @param _user The user address who staked ETH
     * @param _amount The amount of ETH staked
     * @param _timestamp The timestamp when the ETH was staked
     */
    event StakedETH(address _user, uint256 _amount, uint256 _timestamp);

    /**
     * @notice Emitted when the user claims Source as reward for staked ETH
     * @param _user The user address who claimed Source
     * @param _amount The amount of Source tokens claimed
     * @param _timestamp The timestamp when the Source tokens were claimed
     */
    event ClaimedStakeSource(address _user, uint256 _amount, uint256 _timestamp);

    /**
     * @notice Emitted when the user unstaked ETH
     * @param _user The user address who unstaked ETH
     * @param _amount The amount of ETH unstaked
     * @param _timestamp The timestamp when the ETH was unstaked
     */
    event UnstakedETH(address _user, uint256 _amount, uint256 _timestamp);

    /**
     * @notice Emitted when the user claims portions of staked ETH's native yield
     * @param _user The user address who claimed the staked ETH's native yield
     * @param _amount The amount of Yield the user claimed
     * @param _timestamp The timestamp when the Yield was claimed
     */
    event ClaimedStakedETHYield(address _user, uint256 _amount, uint256 _timestamp);
}
