// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

address constant BLAST_ADDRESS = 0x4300000000000000000000000000000000000002;
address constant BLAST_REBASE_ADDRESS = 0x4200000000000000000000000000000000000022;

enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}

enum GasMode {
    VOID,
    CLAIMABLE
}

interface IERC20Rebasing {
    function configure(YieldMode) external returns (uint256);


    function claim(address recipient, uint256 amount) external returns (uint256);

    function getClaimableAmount(address account) external view returns (uint256);
}

interface IBlast {
    function configureClaimableYield() external;

    function claimYield(address contractAddress, address recipientOfYield, uint256 amount) external returns (uint256);

    function configureClaimableGas() external;

    function claimAllYield(address contractAddress, address recipientOfYield) external returns (uint256);

    function readClaimableYield(address contractAddress) external view returns (uint256);

    function configureVoidYield() external;

    function claimMaxGas(address contractAddress, address recipient) external returns (uint256);

    function configureGovernor(address _governor) external;
}

interface IBlastPoints {
	function configurePointsOperator(address operator) external;
}