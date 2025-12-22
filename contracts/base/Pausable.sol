// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./AccessControl.sol";
import "../types/Errors.sol";
import "../types/Events.sol";

abstract contract Pausable is AccessControl {
    mapping(address => bool) private _isPaused;

    modifier notPaused() {
        if (_isPaused[msg.sender]) revert Errors.ContractPaused();
        _;
    }

    function emergencyPause(address _contract) public virtual onlyOwner {
        if (_contract == address(0)) revert Errors.InvalidTarget();
        _isPaused[_contract] = true;
    }

    function emergencyUnpause(address _contract) public virtual onlyOwner {
        if (_contract == address(0)) revert Errors.InvalidTarget();
        _isPaused[_contract] = false;
    }

    function isPaused(address _contract) public view returns (bool) {
        return _isPaused[_contract];
    }
}
