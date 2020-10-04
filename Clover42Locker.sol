pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "./Clover42Token.sol";
import "./Clover42LockerToken.sol";
import "./LockerRole.sol";
import "./UnLockerRole.sol";
import "./__unstable__TokenVault.sol";

contract Clover42Locker is LockerRole, UnLockerRole {
    using SafeMath for uint256;
    using SafeERC20 for Clover42Token;
    using SafeERC20 for Clover42LockerToken;

    // The locker token being delivered
    Clover42LockerToken private _locker_token;
    // The token being locked
    Clover42Token private _token;
    uint256 private _totalLocked;

    __unstable__TokenVault private _vault;

    event TokenUnlocked(address indexed beneficiary, uint256 amount);

    constructor (Clover42Token token, Clover42LockerToken lockerToken) public {
        require(address(token) != address(0), "Clover42Locker: token is the zero address");
        require(address(lockerToken) != address(0), "Clover42Locker: lockerToken is the zero address");
        
        _vault = new __unstable__TokenVault();
        _token = token;
        _locker_token = lockerToken;
        _totalLocked = 0;
    }

    function token() public view returns(Clover42Token) {
        return _token;
    }

    function lockerToken() public view returns(Clover42LockerToken) {
        return _locker_token;
    }

    function totalLocked() public view returns(uint256) {
        return _totalLocked;
    }

    function vault() public view returns(__unstable__TokenVault) {
        return _vault;
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _deliverLockerTokens(address beneficiary, uint256 tokenAmount) internal {
        require(Clover42LockerToken(address(lockerToken())).mint(beneficiary, tokenAmount), 
            "Clover42Locker: Minting LockerToken failed");
    }

    function lock(address beneficiary, uint256 tokenAmount, address lockerVault) public onlyLocker {
        require(beneficiary != address(0), "Clover42Locker: beneficiary is the zero address");
        require(tokenAmount > 0, "Clover42Locker: lock amount is zero");
        _deliverLockerTokens(lockerVault, tokenAmount);
        _totalLocked = _totalLocked.add(tokenAmount);
    }

    function unLock(address beneficiary, uint256 tokenAmount) public onlyUnLocker {
        require(beneficiary != address(0), "Clover42Locker: beneficiary is the zero address");
        require(tokenAmount > 0, "Clover42Locker: unlock amount is zero");
        require(tokenAmount <= _totalLocked, "Clover42Locker: unlock amount exceeded");
        require(tokenAmount <= _locker_token.balanceOf(beneficiary), "Clover42Locker: tokenAmount is larger than the balance of beneficiary");
        _vault._transfer(token(), beneficiary, tokenAmount);
        _totalLocked = _totalLocked.sub(tokenAmount);
        emit TokenUnlocked(beneficiary, tokenAmount);
    }
}


