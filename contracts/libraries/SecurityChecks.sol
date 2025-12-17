// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/Errors.sol";

library SecurityChecks {
    function checkContract(address target) internal view {
        if (target == address(0)) revert Errors.InvalidTarget();
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        if (size == 0) revert Errors.InvalidTarget();
    }

    function checkAuthorization(bool isAuthorized, address caller, address owner) internal pure {
        if (!isAuthorized && caller != owner) {
            revert Errors.NotAuthorized();
        }
    }
}
