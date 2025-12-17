// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/Events.sol";
import "../types/Errors.sol";

abstract contract AccessControl {
    address private _owner;
    mapping(address => bool) private _authorizedContracts;

    constructor() {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != _owner) revert Errors.NotAuthorized();
        _;
    }

    modifier onlyAuthorized() {
        if (!_authorizedContracts[msg.sender] && msg.sender != _owner) {
            revert Errors.NotAuthorized();
        }
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function authorizeContract(address _contract) external onlyOwner {
        if (_contract == address(0)) revert Errors.InvalidTarget();
        _authorizedContracts[_contract] = true;
    }

    function revokeContractAuthorization(address _contract) external onlyOwner {
        if (_contract == address(0)) revert Errors.InvalidTarget();
        _authorizedContracts[_contract] = false;
    }

    function isAuthorized(address _contract) public view returns (bool) {
        return _authorizedContracts[_contract];
    }
}
