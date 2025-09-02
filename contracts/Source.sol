/*

  ______                                                    
 /      \                                                   
/$$$$$$  |  ______   __    __   ______    _______   ______  
$$ \__$$/  /      \ /  |  /  | /      \  /       | /      \ 
$$      \ /$$$$$$  |$$ |  $$ |/$$$$$$  |/$$$$$$$/ /$$$$$$  |
 $$$$$$  |$$ |  $$ |$$ |  $$ |$$ |  $$/ $$ |      $$    $$ |
/  \__$$ |$$ \__$$ |$$ \__$$ |$$ |      $$ \_____ $$$$$$$$/ 
$$    $$/ $$    $$/ $$    $$/ $$ |      $$       |$$       |
 $$$$$$/   $$$$$$/   $$$$$$/  $$/        $$$$$$$/  $$$$$$$/ 
                                                            
                                                            
                                                            
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import {IBlast, BLAST_ADDRESS} from "./interfaces/IBlast.sol";
import {ISource} from "./interfaces/ISource.sol";

/**
 * @notice Source token
 * @author k3rn3lpanic
 */
contract Source is ERC20, Ownable, ISource, ReentrancyGuard {
    IBlast public immutable blast;

    mapping(address => uint256) public yieldAmountClaimed;
    // ______________________Airdrop (Stake)___________________
    mapping(address => uint256) public stakedETHAmount;
    uint256 public totalETHYield;
    uint256 public totalAmountStaked;
    address public socialAirDropAccount;
    // ________________________Settings________________________
    // Normal Vesting
    mapping(address => uint256) public presaleBalance;
    mapping(address => uint256) public presaleClaimed;
    mapping(address => uint256) public lastClaimedTime;
    uint256 public relaseTime = 30 days;  
    uint256 public distributionTime;

    bool public durationEnded = false;
    bool public isMintable = true;
    bool public isDurationEnded = false;
    bool public canBeMinted = true;

    address public constant initialLiquidity = 0xCD99a8bcE4120FCC824eeeeC0bF63f6f1b3CBFC9;
    address public constant ecosystem = 0x7E2038FEE8802507775a4dd73a86070557388659;
    address public constant treasury = 0xC75C6b12A9f3AFB260257543e06Ad7eBBDaAFe30;
    address public constant team1 = 0xf977A77A09A64B6B95a6Dd2472C004F02f270115;
    address public constant team2 = 0x1B30f4a5ea4e8D0195747f6e915497b1dD8b8bCB;
    address public constant CEXListing = 0x3356f424b2C946A1434bDF5F8b7C71717ddEaD25;

    address public constant deployer = 0x3c6778f1A72a50d9E311214293Edbb65CF2ae0a5;


    modifier onlyDeployer {
        require(msg.sender == deployer, "Only deployer can call this function");
        _;
    }

    constructor() ERC20("Source", "SRC") Ownable(msg.sender){
        blast = IBlast(BLAST_ADDRESS);
        blast.configureClaimableYield();
        // _mint(initialLiquidity, 500_000 * 1e18);
        // _mint(ecosystem, 3_000_000 * 1e18);
        // _mint(treasury, 2_000_000 * 1e18);
        // _mint(team1, 500_000 * 1e18);
        // _mint(team2, 500_000 * 1e18);
        // _mint(CEXListing, 600_000 * 1e18);
        // _mint(msg.sender, 1_000_000 * 1e18); // 1m for me
        // _mint(0xA9d0Ca290f7c0Eb1d6c847Cd6e41D8Cf182eB8C4, 9_000_000 * 1e18);
        _mint(0xA9d0Ca290f7c0Eb1d6c847Cd6e41D8Cf182eB8C4, 10_000_000e18);
    }

    function distribute(address[] memory _recipients, uint256[] memory _amounts) public onlyDeployer{
        if (!canBeMinted) revert SourceNotMintable();
        for (uint256 i = 0; i < _recipients.length; i++) {
            _mint(_recipients[i], _amounts[i]);
        }
        distributionTime = block.timestamp;
    }

    function presaleDistribute(address[] memory _presale, uint256[] memory _presaleAmount) public onlyDeployer{
        if (!canBeMinted) revert SourceNotMintable();
        for (uint256 i = 0; i < _presale.length; i++) {
            _mint(_presale[i], _presaleAmount[i]/2);
            presaleBalance[_presale[i]] = _presaleAmount[i]/2;
        }
        distributionTime = block.timestamp;
    }

    function setDistributionTime() public onlyDeployer{
        distributionTime = block.timestamp;
    }

    function setReleaseTime(uint256 _releaseTime) public onlyDeployer{
        relaseTime = _releaseTime;
    }

    function setDistributionTimeFor(uint256 _time) public onlyDeployer{
        distributionTime = _time;
    }

    function closeMinting() public onlyDeployer{
        canBeMinted = false;
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

            _mint(msg.sender, ratio);

            emit PresaleClaimed(
                msg.sender, ratio, presaleBalance[msg.sender] - presaleClaimed[msg.sender], block.timestamp
            );
        } else {

            presaleClaimed[msg.sender] += (presaleBalance[msg.sender] - presaleClaimed[msg.sender]);

            _mint(msg.sender, presaleBalance[msg.sender]);

            emit PresaleClaimed(msg.sender, presaleBalance[msg.sender], 0, block.timestamp);
        }
    }

    /**
     * @notice Helper function for source pool transfer without tax
     * @param _from From user
     * @param _to To user
     * @param _amount The amount
     */
    function sourcePoolTransferFrom(address _from, address _to, uint256 _amount) public onlyOwner {
        address spender = _msgSender();
        _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
    }

    /**
     * @notice Stake ETH for the airdrop distribution and yield rewards
     */
    function stakeETH() public payable nonReentrant{
        // If the duration time is not ended
        if (block.timestamp >= distributionTime + relaseTime) {
            revert StakeDurationEnded();
        }
        uint256 stakedAmount = msg.value;
        stakedETHAmount[msg.sender] += stakedAmount;
        totalAmountStaked += stakedAmount;

        emit StakedETH(msg.sender, stakedAmount, block.timestamp);
    }

    /**
     * @notice Unstake ETH for the airdrop distribution claim and yield rewards
     */
    function unstakeETH() public nonReentrant{
        if (block.timestamp < distributionTime + relaseTime) {
            revert StakeDurationEnded();
        }

        if (stakedETHAmount[msg.sender] == 0) {
            revert NoETHStaked();
        }

        uint256 tempAmount = stakedETHAmount[msg.sender];

        if (!isDurationEnded) {
            uint256 claimableYield = blast.readClaimableYield(address(this));
            isDurationEnded = true;
            blast.claimYield(address(this), address(this), claimableYield);
            totalETHYield += claimableYield;
            durationEnded = true;
        } 

        claimStakedETHYield();
        claimStakeSource();

        totalAmountStaked -= tempAmount;
        stakedETHAmount[msg.sender] = 0;

        payable(msg.sender).transfer(tempAmount);

        emit UnstakedETH(msg.sender, tempAmount, block.timestamp);
    }

    /**
     * @notice Claim Source tokens for staked ETH from the airdrop
     */
    function claimStakeSource() private {
        if (block.timestamp < distributionTime + relaseTime) {
            revert StakeDurationEnded();
        }

        if (stakedETHAmount[msg.sender] == 0) {
            revert NoETHStaked();
        }

        _mint(msg.sender, (stakedETHAmount[msg.sender] * 80_000 * 1e18) / totalAmountStaked);

        emit ClaimedStakeSource(
            msg.sender, (stakedETHAmount[msg.sender] * 80_000 * 1e18) / totalAmountStaked, block.timestamp
        );

        stakedETHAmount[msg.sender] = 0;
    }

    /**
     * @notice Claim Source tokens for staked ETH's native yield
     */
    function claimStakedETHYield() private {
        if (block.timestamp < distributionTime + relaseTime) {
            revert ("The stake duration not ended");
        }

        if (stakedETHAmount[msg.sender] == 0) {
            revert ("No ETH staked");
        }

        uint256 yield = (stakedETHAmount[msg.sender] * totalETHYield) / totalAmountStaked;

        yieldAmountClaimed[msg.sender] += yield;

        payable(msg.sender).transfer(yield);

        emit ClaimedStakedETHYield(msg.sender, yield, block.timestamp);
    }

    function claimableETHYield(address claimer) private view returns (uint256){
        uint256 yield = blast.readClaimableYield(address(this));
        return (stakedETHAmount[claimer] * yield) / totalAmountStaked;
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
