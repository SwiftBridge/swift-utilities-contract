// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";
import "./Constants.sol";
import "../types/Errors.sol";

library BatchLogic {
    function validateBatch(DataTypes.BatchOperation[] calldata operations) internal pure {
        uint256 length = operations.length;
        if (length > Constants.MAX_BATCH_SIZE) revert Errors.BatchTooLarge();
        if (length == 0) revert Errors.NoOperations();
    }

    function distributeGas(uint256 initialGas, uint256 remainingOps) internal view returns (uint256) {
        if (remainingOps == 0) return gasleft();
        return gasleft() / remainingOps;
    }
}
