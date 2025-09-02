/*
 _______   __  __  __ 
/       \ /  |/  |/  |
$$$$$$$  |$$/ $$ |$$ |
$$ |__$$ |/  |$$ |$$ |
$$    $$/ $$ |$$ |$$ |
$$$$$$$/  $$ |$$ |$$ |
$$ |      $$ |$$ |$$ |
$$ |      $$ |$$ |$$ |
$$/       $$/ $$/ $$/ 
                      
                      
                      
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IPills} from "./interfaces/IPills.sol";
import {Tracker} from "./Tracker.sol";
import {PillPool} from "./pools/PillPool.sol";

/**
 * @notice Pills ERC1155 token
 * @author k3rn3lpanic
 */
contract Pills is ERC1155, Ownable, Tracker, IPills {
    uint256 public constant RED = 1;
    uint256 public constant BLUE = 2;

    string public constant name = "Matrix Pills";
    string public constant symbol = "PILLS";

    uint256 public totalSupply;
    PillPool public pillPool;

    constructor() ERC1155("") {}

    /**
     * @notice Set the pill pool
     * @param _pillPool pill pool address
     */
    function setPillPool(PillPool _pillPool) external onlyOwner {
        emit PillPoolChanged(address(pillPool), address(_pillPool));
        pillPool = _pillPool;
    }

    /**
     * @notice Mint given amount of red pills
     * @param _to The recipient
     * @param _amount The number of pills to mint
     */
    function mintRedPill(address _to, uint256 _amount) external onlyOwner trackGas {
        emit MintedRedPill(_to, _amount, block.timestamp);
        totalSupply += _amount;
        pillPool.pillsSetFirstTime(_to);
        _mint(_to, RED, _amount, "");
    }

    /**
     * @notice Mint given amount of blue pills
     * @param _to The recipient
     * @param _amount The number of pills to mint
     */
    function mintBluePill(address _to, uint256 _amount) external onlyOwner trackGas {
        emit MintedBluePill(_to, _amount, block.timestamp);
        totalSupply += _amount;
        pillPool.pillsSetFirstTime(_to);
        _mint(_to, BLUE, _amount, "");
    }

    /**
     * @notice Override safeTransferFrom to claim rewards on transfer
     * @param _from From user
     * @param _to To user
     * @param _id The tokenId
     * @param _amount The amount
     * @param _data Data
     */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes memory _data)
        public
        override
    {
        pillPool.pillsSetFirstTime(_to);
        _safeTransferFrom(_from, _to, _id, _amount, _data);
        pillPool.claimRewardsFor(_from);
        pillPool.claimRewardsFor(_to);
    }

    /**
     * @notice Override safeBatchTransferFrom to claim rewards on transfer
     * @param _from From user
     * @param _to To user
     * @param _ids List of tokenIds
     * @param _amounts List of amounts
     * @param _data Data
     */
    function safeBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _amounts,
        bytes memory _data
    ) public override {
        pillPool.pillsSetFirstTime(_to);
        _safeBatchTransferFrom(_from, _to, _ids, _amounts, _data);
        pillPool.claimRewardsFor(_from);
        pillPool.claimRewardsFor(_to);
    }

    /**
     * @notice
     * @param _account The account to check balance for
     * @return balance The total balance
     */
    function totalBalanceOf(address _account) external view returns (uint256) {
        return balanceOf(_account, RED) + balanceOf(_account, BLUE);
    }

    /**
     * @notice
     * @param _id The id of the token
     * @return _uri The uri
     */
    function uri(uint256 _id) public view virtual override returns (string memory _uri) {
        if (_id == RED) {
            _uri = "https://ipfs.io/ipfs/bafybeiguq2ok3ax5uwrplmmxoupjesfobhbdrks2dqyxgzmj77ajo6ddqi/1.json";
        } else if (_id == BLUE) {
            _uri = "https://ipfs.io/ipfs/bafybeiguq2ok3ax5uwrplmmxoupjesfobhbdrks2dqyxgzmj77ajo6ddqi/2.json";
        }
    }
}
