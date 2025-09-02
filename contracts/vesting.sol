// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MatrixVesting is Ownable{
    mapping(address => uint256) public presaleBalance;
    mapping(address => uint256) public presaleClaimed;
    mapping(address => uint256) public lastClaimedTime;
    uint256 public relaseTime = 30 days;  
    uint256 public distributionTime;
    IERC20 public sourceToken;

    constructor(address source) Ownable(msg.sender){
        sourceToken = IERC20(source);
    }

    /**
     * @notice Thrown when no presale token to withdraw is available
     */
    error NoPresaleTokenToWithdraw();

    /**
     * @notice Emitted when user claims portions of presale Source tokens
     * @param _user The user address who claimed the presale Source tokens
     * @param _amount The amount of Source tokens claimed
     * @param _remaining The remaining Source tokens to claim
     * @param _timestamp The timestamp when the Source tokens were claimed
     */
    event PresaleClaimed(address _user, uint256 _amount, uint256 _remaining, uint256 _timestamp);

    function distribute(address[] memory _recipients, uint256[] memory _amounts) public onlyOwner{
        for (uint256 i = 0; i < _recipients.length; i++) {
            sourceToken.transfer(_recipients[i], _amounts[i]);
        }
    }

    function presaleDistribute(address[] memory _presale, uint256[] memory _presaleAmount) public onlyOwner{
        for (uint256 i = 0; i < _presale.length; i++) {
            sourceToken.transfer(_presale[i], _presaleAmount[i]/2);
            presaleBalance[_presale[i]] = _presaleAmount[i]/2;
        }
    }

    function setDistributionTime() public onlyOwner {
        distributionTime = block.timestamp;
    }

     /**
     * @notice Withdraw presale token from presale amount
     */
    function withdrawPresaleToken() external {
        // if it hasn't ended yet
        if (presaleClaimed[msg.sender] >= presaleBalance[msg.sender]) {
            revert NoPresaleTokenToWithdraw();
        }

        if (block.timestamp < distributionTime + relaseTime) {
            uint256 ratio = (minAmount((block.timestamp - lastClaimedTime[msg.sender]), relaseTime) * presaleBalance[msg.sender]) / relaseTime;
            if (presaleClaimed[msg.sender] + ratio > presaleBalance[msg.sender]) {
                ratio = presaleBalance[msg.sender] - presaleClaimed[msg.sender];
            }

            lastClaimedTime[msg.sender] = block.timestamp;
            presaleClaimed[msg.sender] += ratio;

            sourceToken.transfer(msg.sender, ratio);
            emit PresaleClaimed(
                msg.sender, ratio, presaleBalance[msg.sender] - presaleClaimed[msg.sender], block.timestamp
            );
        } else {

            presaleClaimed[msg.sender] += (presaleBalance[msg.sender] - presaleClaimed[msg.sender]);

            sourceToken.transfer(msg.sender, presaleBalance[msg.sender]);

            emit PresaleClaimed(msg.sender, presaleBalance[msg.sender], 0, block.timestamp);
        }
    }

    function minAmount(uint256 amount1, uint256 amount2 ) internal pure returns (uint256) {
        if (amount1 < amount2) {
            return amount1;
        }
        return amount2;
    }

    /**
     * @notice Get the amount of Source tokens to withdraw from presale
     * @param _user The user
     */
    function getWithdrawPresaleAmount(address _user) public view returns (uint256) {
        uint256 ratio = (minAmount((block.timestamp - lastClaimedTime[_user]), relaseTime) * presaleBalance[_user]) / relaseTime;
        if (presaleClaimed[_user] + ratio > presaleBalance[_user]) {
            ratio = presaleBalance[_user] - presaleClaimed[_user];
        }
        return ratio;
    }

}