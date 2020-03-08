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

    address[] cbs;
    mapping(uint => uint) public betTimeline;
    uint[] recentBetTypeExpire;
    mapping(address => bool) private isBetAdd;

    event BetQuestion(address indexed betId, string question, uint betType);
    event BetClosed(uint indexed _type, address betId);
    constructor() public {
        minBet = 10 ** 16;
        maxBet = 5 * 10 ** 15;
        betTimeline[0] = 30 * 60;
        betTimeline[1] = 1 * 1 days;
        betTimeline[2] = 5 * 1 days;
        allBets.push(address(0));
        recentBetTypeExpire.push(0);
        recentBetTypeExpire.push(0);
        recentBetTypeExpire.push(0);

    }

    function pushBet(address _betAddress, string memory _question, uint _type) public {
        
        allBets.push(_betAddress);
        isBetAdd[_betAddress] = true;
        emit BetQuestion(_betAddress, _question, _type);
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

    function getAllClosedBets() public view returns(address[] memory)
    {
        return cbs;
    }

    function callCloseBetEvent(uint _type) public {
        require(isBetAdd[msg.sender]);
        cbs.push(msg.sender);
        emit BetClosed(_type, msg.sender);
    }

    function changeDependentContractAddress() public onlyInternal {

    }
    

}
