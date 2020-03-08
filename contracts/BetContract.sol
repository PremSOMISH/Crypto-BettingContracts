pragma solidity 0.5.7;

import "./Agree.sol";
import "./Disagree.sol";
import "./BetData.sol";
import "./external/oraclize/ethereum-api/provableAPI_0.5.sol";

contract BetContract is usingProvable {
    using SafeMath for uint;


    uint public startTime;
    uint public expireTime;
    uint public PredictionValue;
    string public FeedSource;
    uint public betType;

    string public stockName;

    Agree public agreeToken;
    Disagree public disagreeToken;
    address payable public AdminAccount;


    uint public minBet;
    uint public maxBet;
    bool public betClosed;
    uint public totalSupplyAtClosing;
    BetData bd;
    uint cx1000;

    mapping(address => uint) public userBettingPointsInFavour;
    mapping(address => uint) public userBettingPointsAgainst;
    mapping(address => bool) public userClaimedReward;
    uint public result;
    uint rewardToDistribute;
    // uint public betTimeline;

    event BetQuestion(address indexed betId, string question, uint betType);

    event Bet(address indexed _user, uint _betAmount, bool _prediction);

    // event CloseBet(address indexed _user, uint _betAmount, bool _prediction);

    event Claimed(address _user, uint _reward);
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
      address bdAdd,
      address payable _admin
    ) 
    public
    payable 
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
      AdminAccount = _admin;
      cx1000 = 6;
      stockName = _question;
      provable_query(_expireTime.sub(now), "URL", _feedSource, 500000);
      emit BetQuestion(address(this), _question, _betType);
    }

    function getPrice(bool prediction) public view returns(uint) {

      uint TS;
      if(prediction) {
        TS = agreeToken.totalSupply();
      } else {
        TS = disagreeToken.totalSupply();
      }
      if(TS.div(1000) > 10 ** 18)
        TS = uint(1000).mul(10 ** 18);
      uint val = (cx1000.add(1000)).mul(TS).div(100);
      if(val < 10 ** 15)
        val = 10 ** 15;

      return val.div(10 ** 6);
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

    function _closeBet(uint _value) internal {
      
      require(now > expireTime);
      require(!betClosed);
      betClosed = true;
      AdminAccount.transfer(uint(address(this).balance).mul(3).div(100));
      rewardToDistribute = address(this).balance;
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

    function claimReward() public {
      require(!userClaimedReward[msg.sender] && betClosed);
      userClaimedReward[msg.sender] = true;
      uint userPoints;
      if(result == 0) {
        userPoints = userBettingPointsAgainst[msg.sender];
      } else if(result == 1) {
        userPoints = userBettingPointsInFavour[msg.sender];
      }
      require(userPoints > 0);
      uint reward = rewardToDistribute.mul(userPoints).div(totalSupplyAtClosing);
      (msg.sender).transfer(reward);
      
      uint agreeTok = agreeToken.balanceOf(msg.sender);
      if(agreeTok > 0)
      {
        agreeToken.forceBurn(msg.sender, agreeTok);
      }
      uint disAgreeTok = disagreeToken.balanceOf(msg.sender);
      if(disAgreeTok > 0)
      {
        disagreeToken.forceBurn(msg.sender, disAgreeTok);
      }
      emit Claimed(msg.sender, reward);

    }

    function __callback(bytes32 myid, string memory result, bytes memory proof) public{
        
        if (msg.sender != provable_cbAddress()) revert();
        uint resultVal = safeParseInt(result);
        _closeBet(resultVal);
    }
    
}
