// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./Constants.sol";

library GasMath {
    function estimateTxGas(
        uint256 dataLength,
        bool hasValue,
        uint256 buffer
    ) internal pure returns (uint256) {
        uint256 baseGas = Constants.BASE_GAS_COST;
        uint256 dataGas = dataLength * Constants.DATA_GAS_PER_BYTE;
        uint256 valueGas = hasValue ? Constants.VALUE_TRANSFER_GAS : 0;
        
        return baseGas + dataGas + valueGas + buffer;
    }

    function calculateSavings(
        uint256 totalGas,
        uint256 percentage
    ) internal pure returns (uint256) {
        return (totalGas * percentage) / 100;
    }
}
