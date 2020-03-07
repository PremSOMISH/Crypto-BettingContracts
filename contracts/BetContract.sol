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

import "./Agree.sol";
import "./Disagree.sol";
import "./BetData.sol";


contract BetContract {
    using SafeMath for uint;


    uint public startTime;
    uint public expireTime;
    uint public PredictionValue;
    string public FeedSource;
    uint public betType;

    Agree public agreeToken;
    Disagree public disagreeToken;


    uint public minBet;
    uint public maxBet;
    bool public betClosed;
    uint public totalSupplyAtClosing;
    BetData bd;
    // address public owner;
    // uint public tokenExponent;

    // enum BetType {Invalid, Low, Medium, High}

    // uint public poolStrength;
    // mapping(address => bool) public userVotedForBet;
    mapping(address => uint) public userBettingPointsInFavour;
    mapping(address => uint) public userBettingPointsAgainst;
    mapping(address => bool) public userClaimedReward;
    uint public result;
    // uint public betTimeline;

    event BetQuestion(address indexed betId, string question, uint betType);

    event Bet(address indexed _user, uint _betAmount, bool _prediction);

    // event CloseBet(address indexed _user, uint _betAmount, bool _prediction);

    // event Claimed();

    constructor(
      uint _minBet,
      uint _maxBet,
      Agree _agree, 
      Disagree _disAgree, 
      string memory _question, 
      uint _betType,
      uint _startTime,
      uint _expireTime,
      uint _predictionValue,
      string memory _feedSource,
      address bdAdd
    ) 
    public 
    {
      minBet = _minBet;
      maxBet = _maxBet;
      agreeToken = _agree;
      disagreeToken = _disAgree;
      startTime = _startTime;
      betType = _betType;
      expireTime = _expireTime;
      PredictionValue = _predictionValue;
      FeedSource = _feedSource;
      agreeToken.changeOperator(address(this));
      disagreeToken.changeOperator(address(this));
      bd = BetData(bdAdd);
      emit BetQuestion(address(this), _question, _betType);
    }

    function getPrice(bool prediction) public view returns(uint) {
      // uint getA;
      // uint getC;
      // uint getCAAvgRate;
      // uint max = (mcrtp.mul(mcrtp).mul(mcrtp).mul(mcrtp));
      // uint max = mcrtp ** tokenExponent;
      // uint dividingFactor = tokenExponent.mul(4); 
      // // (getA, getC, getCAAvgRate) = pd.getTokenPriceDetails(_curr);
      // uint mcrEth = address(this);
      // // getC = getC.mul(DECIMAL1E18);
      // tokenPrice = (mcrEth.mul(DECIMAL1E18).mul(max).div(getC)).div(10 ** dividingFactor);
      // tokenPrice = tokenPrice.add(getA.mul(DECIMAL1E18).div(DECIMAL1E05));
      // // tokenPrice = tokenPrice.mul(getCAAvgRate * 10); 
      // tokenPrice = (tokenPrice).div(10**3);
      return 1;
    }

    function placeBet(bool _prediction) public payable {
      require(now >= startTime && now <= expireTime);
      require(msg.value >= minBet && msg.value <= maxBet);
      uint tokenPrice = getPrice(_prediction);
      uint betValue = uint(msg.value).mul(10**18).div(tokenPrice);
      if(_prediction)
      {
        require(userBettingPointsInFavour[msg.sender] == 0);
        agreeToken.mint(msg.sender, betValue);
        userBettingPointsInFavour[msg.sender] = betValue;
      } else {
        require(userBettingPointsAgainst[msg.sender] == 0);
        disagreeToken.mint(msg.sender, betValue);
        userBettingPointsAgainst[msg.sender] = betValue;
      }
      emit Bet(msg.sender, betValue, _prediction);
    }

    function closeBet(uint _value) public {
      require(msg.sender == address(0)); // have to replace with oracalize address.
      require(now > expireTime);
      require(!betClosed);
      // send all money other than reward to -> pool
      betClosed = true;
      if(_value > PredictionValue)
      {
        totalSupplyAtClosing = agreeToken.totalSupply();
        result = 1;
      } else {
        totalSupplyAtClosing = disagreeToken.totalSupply();
        result = 0;
      }

      bd.callCloseBetEvent(betType); 

    }
    
}
