// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IEmergency {
    function emergencyPause(address _contract) external;
    function emergencyUnpause(address _contract) external;
    function authorizeContract(address _contract) external;
    function revokeContractAuthorization(address _contract) external;
}
