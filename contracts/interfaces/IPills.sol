// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @notice Pills ERC1155 token
 * @author k3rn3lpanic
 */
interface IPills {
    /**
     * @notice Emitted when pill pool is modified
     * @param _from previous pill pool
     * @param _to new pill pool
     */
    event PillPoolChanged(address indexed _from, address indexed _to);

    /**
     * @notice Emitted when a Red pill is minted
     * @param _to Address of the recipient
     * @param _amount The amount of minted pills
     * @param _timestamp The timestamp when the pill was minted
     */
    event MintedRedPill(
        address indexed _to,
        uint256 _amount,
        uint256 _timestamp
    );

    /**
     * @notice Emitted when a Blue pill is minted
     * @param _to Address of the recipient
     * @param _amount The amount of minted pills
     * @param _timestamp The timestamp when the pill was minted
     */
    event MintedBluePill(
        address indexed _to,
        uint256 _amount,
        uint256 _timestamp
    );
}
