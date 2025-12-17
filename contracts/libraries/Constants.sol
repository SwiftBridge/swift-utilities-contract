// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Constants {
    uint256 internal constant MAX_BATCH_SIZE = 50;
    uint256 internal constant GAS_LIMIT_BUFFER = 10000;
    uint256 internal constant EMERGENCY_PAUSE_DURATION = 24 hours;
    uint256 internal constant BASE_GAS_COST = 21000;
    uint256 internal constant DATA_GAS_PER_BYTE = 16;
    uint256 internal constant VALUE_TRANSFER_GAS = 9000;
}
