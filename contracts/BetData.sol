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


contract BetData {
    using SafeMath for uint;

    struct BetStruct {
        uint status;
        uint startTime;
        uint expireTime;
        uint PredictionValue;
        string FeedSource;
        uint betType;
    }

    uint public minBet;
    uint public maxBet;
    address public owner;

    enum BetStatus {NotStarted, InProgress, Ended}
    enum BetType {Invalid, Low, Medium, High}

    BetStruct[] allBets;

    mapping(uint => uint) public poolStrength;
    mapping(address => mapping(uint => bool)) public userVotedForBet;
    mapping(uint => uint) public betTimeline;

    event BetQuestion(uint indexed betId, string question, uint betType);
    constructor(address _owner) public {
        minBet = 10 ** 18;
        maxBet = 10 ** 19;
        betTimeline[1] = 30 * 1 minutes;
        betTimeline[2] = 1 * 1 days;
        betTimeline[3] = 5 * 1 days;
        owner = _owner;
        allBets.push(BetStruct(0, 0, 0, 0, "", 0));
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function pushBet(string memory _betQuestion, uint _startTime, uint _predictionValue, string memory _feedSource, uint _betType) public {
        uint betId = allBets.length;
        allBets.push(BetStruct(uint(BetStatus.NotStarted), _startTime, _startTime.add(betTimeline[_betType]), _predictionValue, _feedSource, _betType));
        emit BetQuestion(betId, _betQuestion, _betType);
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

    function updatePoolStrength(uint _betId, uint _val, bool _bit) public {

        if(_bit){
            poolStrength[_betId] = poolStrength[_betId].add(_val);
        } else {
            poolStrength[_betId] = poolStrength[_betId].sub(_val);
        }

    }
    

}
