pragma solidity >=0.4.25 <0.7.0;

import "@openzeppelin/contracts/GSN/Context.sol";
import "@openzeppelin/contracts/access/Roles.sol";

contract UnLockerRole is Context {
    using Roles for Roles.Role;

    event UnLockerAdded(address indexed account);
    event UnLockerRemoved(address indexed account);

    Roles.Role private _unLockers;

    constructor () internal {
        _addUnLocker(_msgSender());
    }

    modifier onlyUnLocker() {
        require(isUnLocker(_msgSender()), "UnLockerRole: caller does not have the unLocker role");
        _;
    }

    function isUnLocker(address account) public view returns (bool) {
        return _unLockers.has(account);
    }

    function addUnLocker(address account) public onlyUnLocker {
        _addUnLocker(account);
    }

    function renounceUnLocker() public {
        _removeUnLocker(_msgSender());
    }

    function _addUnLocker(address account) internal {
        _unLockers.add(account);
        emit UnLockerAdded(account);
    }

    function _removeUnLocker(address account) internal {
        _unLockers.remove(account);
        emit UnLockerRemoved(account);
    }
}