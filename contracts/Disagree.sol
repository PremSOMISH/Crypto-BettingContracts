pragma solidity 0.5.7;

import "./external/openzeppelin-solidity/math/SafeMath.sol";


contract Disagree {
    using SafeMath for uint256;


    mapping (address => uint256) private _balances;

    uint256 private _totalSupply;

    string public name = "Disagree";
    string public symbol = "Disagree";
    uint8 public decimals = 18;
    address public operator;



    modifier onlyOperator() {
        if (operator != address(0))
            require(msg.sender == operator);
        _;
    }

    event Mint(address indexed account, uint indexed amount);

    event Burn(address indexed account, uint indexed amount);

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    * @dev change operator address 
    * @param _newOperator address of new operator
    */
    function changeOperator(address _newOperator) public onlyOperator returns (bool) {
        operator = _newOperator;
        return true;
    }

    /**
    * @dev function that mints an amount of the token and assigns it to
    * an account.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function mint(address account, uint256 amount) public onlyOperator {
        _mint(account, amount);
    }

    /**
    * @dev Burns a specific amount of tokens from the target address.
    * @param from address The address which you want to burn tokens from
    * @param value uint256 The amount of token to be burned
    */
    function forceBurn(address from, uint256 value) public onlyOperator returns (bool) {

        _totalSupply = _totalSupply.sub(value);
        _balances[from] = _balances[from].sub(value);
        emit Burn(from, value);
        return true;
    }

    /**
    * @dev Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Mint(account, amount);
    }
}