pragma solidity 0.5.7;

import "./Agree.sol";
import "./Disagree.sol";
import "./BetData.sol";
import "./BetContract.sol";
import "./Iupgradable.sol";

contract BetKaroNaa is Iupgradable {
    using SafeMath for uint;

    BetData bd;

    function addNewBet( 
      string memory _question, 
      uint _betType,
      uint _startTime,
      uint _predictionValue,
      string memory _feedSource
      ) public payable onlyOwner {

        Agree _agree = new Agree();
        Disagree _disagree = new Disagree();
        uint _expireTime = _startTime.add(bd.betTimeline(_betType));
        BetContract betCon = (new BetContract).value(msg.value)(bd.minBet(), bd.maxBet(), _agree, _disagree, _question, _betType, _startTime, _expireTime, _predictionValue, _feedSource, address(bd), ms.owner());
        bd.pushBet(address(betCon), _question, _betType);
        bd.updateRecentBetTypeExpire(_betType);
    }

    function changeDependentContractAddress() public onlyInternal {
      bd = BetData(ms.getLatestAddress("BD"));
    }
    
}


