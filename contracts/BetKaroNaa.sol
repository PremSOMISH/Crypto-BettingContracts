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
import "./BetContract.sol";


contract BetKaroNaa {
    using SafeMath for uint;

    BetData bd;

    function addNewBet( 
      string memory _question, 
      uint _betType,
      uint _startTime,
      uint _predictionValue,
      string memory _feedSource
      ) public {

        require(msg.sender == bd.owner());
        Agree _agree = new Agree();
        Disagree _disagree = new Disagree();
        uint _expireTime = _startTime.add(bd.betTimeline(_betType));
        BetContract betCon = new BetContract(bd.minBet(), bd.maxBet(), _agree, _disagree, _question, _betType, _startTime, _expireTime, _predictionValue, _feedSource);
        bd.pushBet(address(betCon));
        bd.updateRecentBetTypeExpire(_betType);
    }
    
}


