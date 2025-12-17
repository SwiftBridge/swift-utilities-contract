// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Events {
    event GasOptimized(
        address indexed user,
        uint256 originalGas,
        uint256 optimizedGas,
        uint256 savings
    );

    event BatchProcessed(
        address indexed user,
        uint256 itemCount,
        uint256 totalGasUsed
    );

    event EmergencyPause(
        address indexed admin,
        uint256 timestamp
    );

    event EmergencyUnpause(
        address indexed admin,
        uint256 timestamp
    );

    event ContractAuthorized(address indexed contractAddress);
    event AuthorizationRevoked(address indexed contractAddress);
}
