pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/ownership/Secondary.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title __unstable__TokenVault
 * @dev Similar to an Escrow for tokens, this contract allows its primary account to spend its tokens as it sees fit.
 * This contract is an internal helper for PostDeliveryCrowdsale, and should not be used outside of this context.
 */
contract __unstable__TokenVault is Secondary {
    function _transfer(IERC20 token, address to, uint256 amount) public onlyPrimary {
        token.transfer(to, amount);
    }
}
