/* Copyright (C) 2017 NexusMutual.io

  This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

  This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
    along with this program.  If not, see http://www.gnu.org/licenses/ */

pragma solidity 0.5.7;

import "./external/openzeppelin-solidity/math/SafeMath.sol";
import "./Iupgradable.sol";


contract BKNMaster {
    using SafeMath for uint;



    bytes2[] internal allContractNames;
    mapping(address => bool) public contractsActive;
    mapping(bytes2 => address payable) internal allContractVersions;


    Iupgradable internal up;


    bool internal constructorCheck;
    address public owner;
    address masterAddress;

    constructor() public {
        owner = msg.sender;
        masterAddress = address(this);
        contractsActive[address(this)] = true; //1
        contractsActive[address(this)] = true;
        _addContractNames();
    }

    /**
     * @dev Handles the Callback of the Oraclize Query.
     * @param myid Oraclize Query ID identifying the query for which the result is being received
     */ 
    // function delegateCallBack(bytes32 myid) external noReentrancy {
    //     PoolData pd = PoolData(getLatestAddress("PD"));
    //     bytes4 res = pd.getApiIdTypeOf(myid);
    //     uint callTime = pd.getDateAddOfAPI(myid);
    //     if (!isPause()) { // system is not in emergency pause
    //         uint id = pd.getIdOfApiId(myid);
    //         if (res == "COV") {
    //             Quotation qt = Quotation(getLatestAddress("QT"));
    //             qt.expireCover(id);                
    //         } else if (res == "CLA") {
    //             cr = ClaimsReward(getLatestAddress("CR"));
    //             cr.changeClaimStatus(id);                
    //         } else if (res == "MCRF") {
    //             if (callTime.add(pd.mcrFailTime()) < now) {
    //                 MCR m1 = MCR(getLatestAddress("MC"));
    //                 m1.addLastMCRData(uint64(id));                
    //             }
    //         } else if (res == "ULT") {
    //             if (callTime.add(pd.liquidityTradeCallbackTime()) < now) {
    //                 Pool2 p2 = Pool2(getLatestAddress("P2"));
    //                 p2.externalLiquidityTrade();        
    //             }
    //         }
    //     } else if (res == "EP") {
    //         if (callTime.add(pauseTime) < now) {
    //             bytes4 by;
    //             (, , by) = getLastEmergencyPause();
    //             if (by == "AB") {
    //                 addEmergencyPause(false, "AUT"); //set pause to false                
    //             }
    //         }
    //     }

    //     if (res != "") 
    //         pd.updateDateUpdOfAPI(myid);
    // }
    
    /**
     * @dev to get the address parameters 
     * @param code is the code associated in concern
     * @return codeVal which is given as input
     * @return the value that is required
     */
    function getAddressParameters(bytes8 code) external view returns(bytes8 codeVal, address val) {

        codeVal = code;

        if (code == "MASTADD") {

            val = masterAddress;

        }  
        
    }

    function masterInitialized() public view returns(bool) {
        return constructorCheck;
    }


    /// @dev upgrades a single contract
    function upgradeContract(bytes2 _contractsName, address payable _contractsAddress) public {
        
        require(_contractsAddress != address(0));

        require(_contractsName == "BK", "Not upgradable contract");

        require(msg.sender == owner);
        
        
        contractsActive[allContractVersions[_contractsName]] = false;
        allContractVersions[_contractsName] = _contractsAddress;

        changeMasterAddress(masterAddress);
        _changeAllAddress();
    }

    /// @dev checks whether the address is a latest contract address.
    function isInternal(address _add) public view returns(bool check) {
        check = false; // should be 0
        if (contractsActive[_add] == true) //remove owner for production release
            check = true;
    }

    /// @dev checks whether the address is the Owner or not.
    function isOwner(address _add) public view returns(bool check) {
        return check = owner == _add;
    }

    /// @dev Changes Master contract address
    function changeMasterAddress(address _masterAddress) public {

        BKNMaster ms = BKNMaster(_masterAddress);
        require(ms.masterInitialized());

        require(msg.sender == owner);
        for (uint i = 0; i < allContractNames.length; i++) {
            
            up = Iupgradable(allContractVersions[allContractNames[i]]);
            up.changeMasterAddress(_masterAddress);
            
        }
        // _changeAllAddress();
        contractsActive[address(this)] = false;
        contractsActive[_masterAddress] = true;
       
    }



    ///@dev Changes owner of the contract.
    ///     In future, in most places onlyOwner to be replaced by onlyAuthorizedToGovern
    function changeOwner(address to) external {
        require(msg.sender == owner);
        owner = to;
    }


    /// @dev Gets latest version name and address
    /// @return contractsName Latest version's contract names
    /// @return contractsAddress Latest version's contract addresses
    function getVersionData() 
        public 
        view 
        returns (
            bytes2[] memory contractsName,
            address[] memory contractsAddress
        ) 
    {
        contractsName = new bytes2[](allContractNames.length);
        contractsAddress = new address[](allContractNames.length);

        for (uint i = 0; i < allContractNames.length; i++) {
            contractsName[i] = allContractNames[i];
            contractsAddress[i] = allContractVersions[allContractNames[i]];
        }
    }

    /// @dev Gets latest contract address
    /// @param _contractName Contract name to fetch
    function getLatestAddress(bytes2 _contractName) public view returns(address payable contractAddress) {
        contractAddress =
            allContractVersions[_contractName];
    }

    /// @dev Creates a new version of contract addresses
    /// @param _contractAddresses Array of contract addresses which will be generated
    function addNewVersion(address payable[] memory _contractAddresses) public {

        require(msg.sender == owner && !constructorCheck);
        require(_contractAddresses.length == allContractNames.length, "array length not same");
        constructorCheck = true;


        for (uint i = 0; i < allContractNames.length; i++) {
            require(_contractAddresses[i] != address(0));

            allContractVersions[allContractNames[i]] = _contractAddresses[i];


        }

    
        changeMasterAddress(address(this));
        _changeAllAddress();
        
    }

    /// @dev Save the initials of all the contracts
    function _addContractNames() internal {
        allContractNames.push("BD");
        allContractNames.push("BK");
    }

    /// @dev Sets the older versions of contract addresses as inactive and the latest one as active.
    function _changeAllAddress() internal {
        uint i;
        for (i = 0; i < allContractNames.length; i++) {
            
            contractsActive[allContractVersions[allContractNames[i]]] = true;
            up = Iupgradable(allContractVersions[allContractNames[i]]);
            up.changeDependentContractAddress();
            
        }
    }  

}
