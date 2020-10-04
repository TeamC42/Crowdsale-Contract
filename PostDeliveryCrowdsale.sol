import "@openzeppelin/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Clover42Locker.sol";
import "./Clover42LockerToken.sol";

/**
 * @title PostDeliveryCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it ends.
 */
contract PostDeliveryCrowdsale is TimedCrowdsale {
    using SafeMath for uint256;

    mapping(address =&gt; uint256) private _balances;
    mapping(address =&gt; uint256) private _locker_balances;
    __unstable__TokenVault private _vault;
    __unstable__TokenVault private _locker_valut;

    
    Clover42Locker private _locker;

    Clover42LockerToken private _locker_token;

    uint256 private _rate;

    constructor(Clover42Locker locker, uint256 rate, Clover42LockerToken lockerToken) public {
        _vault = new __unstable__TokenVault();
        _locker_valut = new __unstable__TokenVault();
        _locker = locker;
        _rate = rate;
        _locker_token = lockerToken;
    }

    function locker() public view returns(Clover42Locker) {
        return _locker;
    }

    function lockRate() public view returns(uint256) {
        return _rate;
    }

    function lockerToken() public view returns(Clover42LockerToken) {
        return _locker_token;
    }

    /**
     * @dev Withdraw tokens only after crowdsale ends.
     * @param beneficiary Whose tokens will be withdrawn.
     */
    function withdrawTokens(address beneficiary) internal {
        uint256 amount = _balances[beneficiary];
        uint256 lockerTokenAmount = _locker_balances[beneficiary];
        require(amount &gt; 0, "PostDeliveryCrowdsale: beneficiary is not due any tokens");
        require(lockerTokenAmount &gt; 0, "PostDeliveryCrowdsale: beneficiary is not due any locker tokens");

        _balances[beneficiary] = 0;
        _locker_balances[beneficiary] = 0;
        _vault._transfer(token(), beneficiary, amount);
        _locker_valut._transfer(lockerToken(), beneficiary, lockerTokenAmount);
    }

    /**
     * @return the balance of an account.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function balanceOfLockerToken(address account) public view returns(uint256) {
        return _locker_balances[account];
    }

    /**
     * @dev Overrides parent by storing due balances, and delivering tokens to the vault instead of the end user. This
     * ensures that the tokens will be available by the time they are withdrawn (which may not be the case if
     * `_deliverTokens` was called later).
     * @param beneficiary Token purchaser
     * @param tokenAmount Amount of tokens purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        uint256 lockAmount = tokenAmount.mul(lockRate()).div(10);
        uint256 withdrawAmount = tokenAmount.sub(lockAmount);
        _balances[beneficiary] = _balances[beneficiary].add(withdrawAmount);
        _locker_balances[beneficiary] = _locker_balances[beneficiary].add(lockAmount);
        _deliverTokens(address(_vault), withdrawAmount);
        _deliverTokens(address(locker().vault()), lockAmount);
        locker().lock(beneficiary, lockAmount, address(_locker_valut));
    }
}