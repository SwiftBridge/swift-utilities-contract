// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IGasEstimator {
    function estimateGas(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external view returns (uint256 estimatedGas);
}
