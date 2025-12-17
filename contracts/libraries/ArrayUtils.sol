// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../types/DataTypes.sol";

library ArrayUtils {
    function reverseOperations(
        DataTypes.BatchOperation[] memory operations
    ) internal pure returns (DataTypes.BatchOperation[] memory) {
        uint256 length = operations.length;
        DataTypes.BatchOperation[] memory reversed = new DataTypes.BatchOperation[](length);
        
        for (uint256 i = 0; i < length;) {
            reversed[i] = operations[length - 1 - i];
            unchecked { ++i; }
        }
        
        return reversed;
    }
}
