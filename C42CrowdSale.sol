pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/crowdsale/Crowdsale.sol";
import "@openzeppelin/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/validation/PausableCrowdsale.sol";
import "@openzeppelin/contracts/crowdsale/distribution/FinalizableCrowdsale.sol";
import "./PostDeliveryCrowdsale.sol";
import "./Clover42Token.sol";
import "./Clover42LockerToken.sol";

contract C42CrowdSale is
    CappedCrowdsale,
    MintedCrowdsale,
    PausableCrowdsale,
    FinalizableCrowdsale,
    PostDeliveryCrowdsale
{
    bool private _finalized;
    address private owner;
    
    constructor(
        uint256 rate,
        uint256 cap,
        address payable wallet,
        uint256 openingTime,
        uint256 closingTime,
        uint256 lockRate,
        Clover42Token token,
        Clover42LockerToken lockerToken,
        Clover42Locker locker
    )
        public
        CappedCrowdsale(cap)
        Crowdsale(rate, wallet, token)
        TimedCrowdsale(openingTime, closingTime)
        PostDeliveryCrowdsale(locker, lockRate, lockerToken)
    {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "C42CrowdSale: must be called by owner");
        _;
    }

    function finalized() public view returns (bool) {
        return _finalized;
    }

    function _finalization() internal {
        super._finalization();
    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {
        return weiAmount.mul(rate());
    }

    function finalize() public onlyOwner {
        require(!finalized(), "C42CrowdSale: already finalized");

        _finalized = true;

        _finalization();
        emit CrowdsaleFinalized();
    }

    function withdraw(address beneficiary) public {
        require(finalized(), "FinalizableCrowdsale: not finalized");
        withdrawTokens(beneficiary);
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal onlyWhileOpen view {
        require(!finalized(), "FinalizableCrowdsale: already finalized");
        super._preValidatePurchase(beneficiary, weiAmount);
    }
}