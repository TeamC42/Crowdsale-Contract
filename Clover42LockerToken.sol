pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20Burnable.sol";

contract Clover42LockerToken is 
    ERC20,
    ERC20Detailed,
    ERC20Mintable,
    ERC20Burnable
{
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals,
        uint256 totalSupply
    ) public ERC20Detailed(name, symbol, decimals) {
    }
}