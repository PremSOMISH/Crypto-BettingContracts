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


contract BetData is Iupgradable {
    using SafeMath for uint;

    uint public minBet;
    uint public maxBet;

    enum BetStatus {NotStarted, InProgress, Ended}
    enum BetType {Invalid, Low, Medium, High}

    address[] public allBets;



    mapping(uint => uint) public betTimeline;
    uint[] recentBetTypeExpire;
    mapping(address => bool) private isBetAdd;

    event BetQuestion(uint indexed betId, string question, uint betType);
    event BetClosed(uint indexed _type, address betId);
    constructor() public {
        minBet = 10 ** 18;
        maxBet = 10 ** 19;
        betTimeline[1] = 30 * 1 minutes;
        betTimeline[2] = 1 * 1 days;
        betTimeline[3] = 5 * 1 days;
        allBets.push(address(0));
    }

    function pushBet(address _betAddress) public {
        
        allBets.push(_betAddress);
        isBetAdd[_betAddress] = true;
    }

    function getAllBetsLen() public view returns(uint)
    {
        return allBets.length;
    }

    function setMinBet(uint _val) public onlyOwner {
        minBet = _val;
    }

    function setMaxBet(uint _val) public onlyOwner {
        maxBet = _val;
    }

    function updateBetTimeline(uint _type, uint _val) public onlyOwner {
        require(_type > 0 && _type < 4);
        betTimeline[_type] = _val;
    }

    function updateRecentBetTypeExpire(uint _type) public {
        recentBetTypeExpire[_type] = now;
    }

    function getRecentBetTypeExpire() public view returns(uint[] memory)
    {
        return recentBetTypeExpire;
    }

    function callCloseBetEvent(uint _type) public {
        require(isBetAdd[msg.sender]);
        emit BetClosed(_type, msg.sender);
    }

    function changeDependentContractAddress() public onlyInternal {

    }
    

}
