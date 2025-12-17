// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract DataTypes {
    struct GasEstimate {
        uint256 gasUsed;
        uint256 gasPrice;
        uint256 totalCost;
        uint256 timestamp;
    }

    struct BatchOperation {
        address target;
        bytes data;
        uint256 value;
        bool success;
        bytes returnData;
    }
}
