pragma solidity 0.5.7;

import "./BKNMaster.sol";


contract Iupgradable {

    BKNMaster public ms;

    modifier onlyInternal {
        require(ms.isInternal(msg.sender));
        _;
    }

    modifier onlyOwner {
        require(ms.isOwner(msg.sender));
        _;
    }

    /**
     * @dev Iupgradable Interface to update dependent contract address
     */
    function  changeDependentContractAddress() public;

    /**
     * @dev change master address
     * @param _masterAddress is the new address
     */
    function changeMasterAddress(address _masterAddress) public {
        if (address(ms) != address(0)) {
            require(address(ms) == msg.sender, "Not master");
        }
        ms = BKNMaster(_masterAddress);
    }

}