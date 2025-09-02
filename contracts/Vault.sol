// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
}

contract MatrixVault is Ownable {
    address public tradeableSourceAddress;
    address public sourceAddress;
    address private taxSupplier;

    // Events
    event Deposit(address indexed user, address indexed token, uint256 amount);
    event Exchange(address indexed user, address indexed fromToken, address indexed toToken, uint256 fromAmount, uint256 toAmount);

    error InvalidToken();
    error InsufficientBalance();
    error AmountZero();

    modifier preventReentrant() {
        require(!locked, "ReentrancyGuard: reentrant call");
        locked = true;
        _;
        locked = false;
    }
    bool private locked;

    constructor(address _tradeableSourceAddress, address _sourceAddress, address _taxSupplier) Ownable(msg.sender){
        tradeableSourceAddress = _tradeableSourceAddress;
        sourceAddress = _sourceAddress;
        taxSupplier = _taxSupplier;
    }

    function setTradeableSourceAddress(address _tradeableSourceAddress) external onlyOwner {
        tradeableSourceAddress = _tradeableSourceAddress;
    }

    function setSourceAddress(address _sourceAddress) external onlyOwner {
        sourceAddress = _sourceAddress;
    }

    // todo: check for approvals on transfer from
    function exchange(uint256 depositAmount, address depositToken) external preventReentrant {
        if (depositAmount == 0) revert AmountZero();
        if (depositToken != tradeableSourceAddress && depositToken != sourceAddress) revert InvalidToken();

        address exchangeToken = (depositToken == tradeableSourceAddress) ? sourceAddress : tradeableSourceAddress;
        IERC20(depositToken).transferFrom(msg.sender, address(this), depositAmount);

        // Deposit
        if (depositToken == sourceAddress && exchangeToken == tradeableSourceAddress){
            uint256 newDepositAmount = (depositAmount * 97) / 100;
            uint256 taxToCover = ((depositAmount - newDepositAmount) * 100) / 97;
            IERC20(depositToken).transferFrom(taxSupplier, address(this), taxToCover);
        }
        // Exchange
        uint256 exchangeAmount = depositAmount;
        if (depositToken == tradeableSourceAddress && exchangeToken == sourceAddress) {
            exchangeAmount = (depositAmount * 100) / 97; // Covering up the 3% tax on withdraw from source
            uint256 taxAmountToCover = ((exchangeAmount - depositAmount) * 100) / 97;
            IERC20(sourceAddress).transferFrom(taxSupplier, address(this), taxAmountToCover);
        }
        IERC20(exchangeToken).transfer(msg.sender, exchangeAmount);

        // Emitting events
        emit Exchange(msg.sender, depositToken, exchangeToken, depositAmount, exchangeAmount);
    }
}
