// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./interfaces/IUtilitiesV2.sol";
import "./base/Pausable.sol";
import "./base/ReentrancyGuard.sol";
import "./libraries/GasMath.sol";
import "./libraries/BatchLogic.sol";
import "./libraries/TokenHelper.sol";
import "./libraries/ArrayUtils.sol";
import "./libraries/SecurityChecks.sol";
import "./libraries/Constants.sol";
import "./types/DataTypes.sol";
import "./types/Events.sol";
import "./types/Errors.sol";
import "./types/Errors.sol";
import "./base/AccessControl.sol";
import "./interfaces/IEmergency.sol";

contract UtilitiesV2 is IUtilitiesV2, Pausable, ReentrancyGuard, Events {
    mapping(address => DataTypes.GasEstimate[]) public gasEstimates;

    constructor() {}

    function estimateGas(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external view returns (uint256 estimatedGas) {
        SecurityChecks.checkContract(_target);
        return GasMath.estimateTxGas(_data.length, _value > 0, Constants.GAS_LIMIT_BUFFER);
    }

    function executeBatch(
        DataTypes.BatchOperation[] calldata _operations
    ) 
        external 
        payable 
        nonReentrant 
        notPaused 
        returns (DataTypes.BatchOperation[] memory results) 
    {
        BatchLogic.validateBatch(_operations);

        uint256 gasStart = gasleft();
        uint256 length = _operations.length;
        results = new DataTypes.BatchOperation[](length);

        for (uint256 i = 0; i < length;) {
            DataTypes.BatchOperation memory op = _operations[i];
            
            (bool success, bytes memory returnData) = op.target.call{
                value: op.value,
                gas: BatchLogic.distributeGas(gasStart, length - i)
            }(op.data);

            results[i] = DataTypes.BatchOperation({
                target: op.target,
                data: op.data,
                value: op.value,
                success: success,
                returnData: returnData
            });

            unchecked { ++i; }
        }

        uint256 gasUsed = gasStart - gasleft();
        emit BatchProcessed(msg.sender, length, gasUsed);
        
        gasEstimates[msg.sender].push(DataTypes.GasEstimate({
            gasUsed: gasUsed,
            gasPrice: tx.gasprice,
            totalCost: gasUsed * tx.gasprice,
            timestamp: block.timestamp
        }));
    }

    function getBalance(address _token, address _account) external view returns (uint256) {
        if (_token == address(0)) {
            return _account.balance;
        }
        return IERC20(_token).balanceOf(_account);
    }

    function transfer(address _token, address _to, uint256 _amount) external payable nonReentrant {
        if (_token == address(0)) {
            TokenHelper.safeTransferETH(_to, _amount);
        } else {
            TokenHelper.safeTransferFrom(_token, msg.sender, _to, _amount);
        }
    }

    function approve(address _token, address _spender, uint256 _amount) external onlyOwner {
        if (_token == address(0)) revert Errors.InvalidToken();
        if (_spender == address(0)) revert Errors.InvalidSpender();
        IERC20(_token).approve(_spender, _amount);
    }

    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        if (balance == 0) revert Errors.NoBalanceToWithdraw();
        TokenHelper.safeTransferETH(owner(), balance);
    }

    function withdrawTokens(address _token, uint256 _amount) external onlyOwner nonReentrant {
        TokenHelper.safeTransfer(_token, owner(), _amount);
    }

    function isContract(address _address) external view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    // Solves inheritance conflict between AccessControl/Pausable and IEmergency
    function authorizeContract(address _contract) public override(AccessControl, IEmergency) {
        super.authorizeContract(_contract);
    }

    function revokeContractAuthorization(address _contract) public override(AccessControl, IEmergency) {
        super.revokeContractAuthorization(_contract);
    }

    function emergencyPause(address _contract) public override(Pausable, IEmergency) {
        super.emergencyPause(_contract);
    }

    function emergencyUnpause(address _contract) public override(Pausable, IEmergency) {
        super.emergencyUnpause(_contract);
    }
}
