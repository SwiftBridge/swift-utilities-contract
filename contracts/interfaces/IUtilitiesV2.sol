// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./IGasEstimator.sol";
import "./IBatchExecutor.sol";
import "./ITokenUtils.sol";
import "./IEmergency.sol";

interface IUtilitiesV2 is IGasEstimator, IBatchExecutor, ITokenUtils, IEmergency {
    function isContract(address _address) external view returns (bool);
}
