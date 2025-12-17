// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";

interface IBatchExecutor {
    function executeBatch(
        DataTypes.BatchOperation[] calldata _operations
    ) external payable returns (DataTypes.BatchOperation[] memory results);
}
