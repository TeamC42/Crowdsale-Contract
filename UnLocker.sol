pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Clover42Token.sol";
import "./Clover42LockerToken.sol";
import "./Clover42Locker.sol";

contract UnLocker is Context {
    using SafeMath for uint256;

    Clover42Locker private _locker;
    Clover42LockerToken private _locker_token;
    Clover42Token private _token;

    address private owner;

    mapping(address => uint256) private _balances;

    constructor (Clover42Locker locker, Clover42LockerToken lockerToken, Clover42Token token) public {
        require(address(lockerToken) != address(0), "Clover42Locker: lockerToken is the zero address");

        _locker_token = lockerToken;
        _locker = locker;
        _token = token;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "C42CrowdSale: must be called by owner");
        _;
    }

    function _unlock(uint256 tokenAmount) internal {
        _locker.unLock(address(this), tokenAmount);
        _locker_token.burn(tokenAmount);
    }

    function _withdraw(address beneficiary, uint256 tokenAmount) internal {
        _token.transfer(beneficiary, tokenAmount);
        _balances[beneficiary] = _balances[beneficiary].sub(tokenAmount);
    }

    function unlock(address beneficiary, uint256 tokenAmount) public {
        require(tokenAmount > 0, "UnLocker: token amount can not be zero");
        require(tokenAmount <= _locker_token.balanceOf(address(this)), "UnLocker: locker token amount exceeds balance of contract");
        require(tokenAmount <= _balances[beneficiary], "UnLocker: token amount exceeds balance of beneficiary");

        _unlock(tokenAmount);
    }

    function withdraw(address beneficiary, uint256 tokenAmount) public {
        require(beneficiary != address(0), "UnLocker: beneficiary is the zero address");
        require(tokenAmount <= _token.balanceOf(address(this)), "UnLocker: token amount exceeds balance of contract");
        require(tokenAmount <= _balances[beneficiary], "UnLocker: token amount exceeds balance of beneficiary");

        _withdraw(beneficiary, tokenAmount);
    }

    // before call this method, user must call approve of lockerToken
    function pledge(address beneficiary, uint256 tokenAmount) public {
        require(beneficiary != address(0), "UnLocker: beneficiary is the zero address");
        require(tokenAmount <= _locker_token.allowance(beneficiary, address(this)), 
            "UnLocker: lockerTokenAmount exceeds allowance of contract");
        // transfer token to this contract
        _locker_token.transferFrom(beneficiary, address(this), tokenAmount);
        _balances[beneficiary] = _balances[beneficiary].add(tokenAmount);
    }
}
