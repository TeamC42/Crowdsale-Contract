pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/access/Roles.sol";

contract LockerRole is Context {
    using Roles for Roles.Role;

    event LockerAdded(address indexed account);
    event LockerRemoved(address indexed account);

    Roles.Role private _lockers;

    constructor () internal {
        _addLocker(_msgSender());
    }

    modifier onlyLocker() {
        require(isLocker(_msgSender()), "LockerRole: caller does not have the locker role");
        _;
    }

    function isLocker(address account) public view returns (bool) {
        return _lockers.has(account);
    }

    function addLocker(address account) public onlyLocker {
        _addLocker(account);
    }

    function renounceLocker() public {
        _removeLocker(_msgSender());
    }

    function _addLocker(address account) internal {
        _lockers.add(account);
        emit LockerAdded(account);
    }

    function _removeLocker(address account) internal {
        _lockers.remove(account);
        emit LockerRemoved(account);
    }
}