// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

/**
 * @title Utilities
 * @notice A utility contract with helper functions for Swift v2 platform
 * @dev Implements gas estimation, batch processing, and token utilities
 * @author Swift v2 Team
 */
contract Utilities is ReentrancyGuard, Ownable {
    using Counters for Counters.Counter;

    // Events
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

    // Errors
    error InvalidTarget();
    error BatchTooLarge();
    error NoOperations();
    error InvalidRecipient();
    error InvalidAmount();
    error InsufficientETH();
    error TransferFailed();
    error InvalidToken();
    error InvalidSpender();
    error NotAuthorized();
    error ContractPaused();
    error NoBalanceToWithdraw();
    error TokenTransferFailed();

    // Structs
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

    // State variables
    mapping(address => GasEstimate[]) public gasEstimates;
    mapping(address => bool) public authorizedContracts;
    mapping(address => bool) public isPaused;
    
    // Constants
    /// @dev Maximum number of operations allowed in a single batch
    uint256 public constant MAX_BATCH_SIZE = 50;
    /// @dev Gas buffer to add to estimates to prevent out-of-gas errors
    uint256 public constant GAS_LIMIT_BUFFER = 10000;
    /// @dev Duration for which the contract can be emergency paused
    uint256 public constant EMERGENCY_PAUSE_DURATION = 24 hours;

    // Modifiers
    modifier onlyAuthorized() {
        if (!authorizedContracts[msg.sender] && msg.sender != owner()) {
            revert NotAuthorized();
        }
        _;
    }

    modifier notPaused() {
        if (isPaused[msg.sender]) {
            revert ContractPaused();
        }
        _;
    }

    constructor() {}

    /**
     * @notice Estimate gas usage for a potential transaction
     * @dev Simplistic estimation including base cost and data cost
     * @param _target Target contract address
     * @param _data Transaction data payload
     * @param _value ETH value to send in wei
     * @return estimatedGas Total estimated gas usage including buffer
     */
    function estimateGas(
        address _target,
        bytes calldata _data,
        uint256 _value
    ) external view returns (uint256 estimatedGas) {
        if (_target == address(0)) revert InvalidTarget();
        
        uint256 gasStart = gasleft();
        
        // This is a simplified estimation
        // In practice, you'd use more sophisticated gas estimation
        uint256 baseGas = 21000; // Base transaction cost
        uint256 dataGas = _data.length * 16; // 16 gas per byte
        uint256 valueGas = _value > 0 ? 9000 : 0; // Additional gas for value transfer
        
        estimatedGas = baseGas + dataGas + valueGas + GAS_LIMIT_BUFFER;
        
        return estimatedGas;
    }

    /**
     * @notice Execute multiple operations in a single transaction
     * @dev Distributes remaining gas among operations
     * @param _operations Array of BatchOperation structs to execute
     * @return results Array of BatchOperation structs containing execution results
     */
    function executeBatch(
        BatchOperation[] calldata _operations
    ) 
        external 
        payable 
        nonReentrant 
        notPaused 
        returns (BatchOperation[] memory results) 
    {
        uint256 length = _operations.length;
        if (length > MAX_BATCH_SIZE) revert BatchTooLarge();
        if (length == 0) revert NoOperations();

        uint256 gasStart = gasleft();
        results = new BatchOperation[](length);

        for (uint256 i = 0; i < length;) {
            BatchOperation memory operation = _operations[i];
            
            (bool success, bytes memory returnData) = operation.target.call{
                value: operation.value,
                gas: gasleft() / (length - i) // Distribute remaining gas
            }(operation.data);

            results[i] = BatchOperation({
                target: operation.target,
                data: operation.data,
                value: operation.value,
                success: success,
                returnData: returnData
            });
            unchecked { ++i; }
        }

        uint256 gasUsed = gasStart - gasleft();
        gasEstimates[msg.sender].push(GasEstimate({
            gasUsed: gasUsed,
            gasPrice: tx.gasprice,
            totalCost: gasUsed * tx.gasprice,
            timestamp: block.timestamp
        }));

        emit BatchProcessed(msg.sender, _operations.length, gasUsed);
    }

    /**
     * @notice Reorder operations to potentially optimize gas usage
     * @dev Currently performs a simple pass-through; placeholder for advanced sorting
     * @param _operations Array of operations to optimize
     * @return optimizedOperations The reordered array of operations
     */
    function optimizeGasUsage(
        BatchOperation[] calldata _operations
    ) external pure returns (BatchOperation[] memory optimizedOperations) {
        // This is a simplified optimization
        // In practice, you'd implement more sophisticated algorithms
        
        uint256 length = _operations.length;
        optimizedOperations = new BatchOperation[](length);
        
        // Sort operations by gas cost (simplified)
        for (uint256 i = 0; i < length;) {
            optimizedOperations[i] = _operations[i];
            unchecked { ++i; }
        }
        
        return optimizedOperations;
    }

    /**
     * @notice Check if an address is a contract
     * @dev Checks code size; note that this returns false for contracts in construction
     * @param _address Address to check
     * @return True if the address has code size > 0, false otherwise
     */
    function isContract(address _address) external view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    /**
     * @notice Get the ETH or ERC20 token balance of an account
     * @param _token Token address (use address(0) for ETH)
     * @param _account Account address to query
     * @return balance The balance of the token or ETH
     */
    function getBalance(address _token, address _account) external view returns (uint256 balance) {
        if (_token == address(0)) {
            return _account.balance;
        } else {
            return IERC20(_token).balanceOf(_account);
        }
    }

    /**
     * @notice Transfer tokens or ETH to a recipient
     * @dev Handles both ETH (address(0)) and ERC20 transfers
     * @param _token Token address (use address(0) for ETH)
     * @param _to Recipient address
     * @param _amount Amount to transfer in wei or token units
     */
    function transfer(
        address _token,
        address _to,
        uint256 _amount
    ) external payable nonReentrant {
        if (_to == address(0)) revert InvalidRecipient();
        if (_amount == 0) revert InvalidAmount();

        if (_token == address(0)) {
            if (msg.value < _amount) revert InsufficientETH();
            (bool success, ) = payable(_to).call{value: _amount}("");
            if (!success) revert TransferFailed();
        } else {
            IERC20(_token).transferFrom(msg.sender, _to, _amount);
        }
    }

    /**
     * @dev Approve token spending
     * @notice WARNING: This function approves on behalf of this contract, not the caller
     * @notice Users should approve tokens directly, not through this function
     * @param _token Token address
     * @param _spender Spender address
     * @param _amount Amount to approve
     */
    function approve(
        address _token,
        address _spender,
        uint256 _amount
    ) external onlyOwner {
        if (_token == address(0)) revert InvalidToken();
        if (_spender == address(0)) revert InvalidSpender();

        IERC20(_token).approve(_spender, _amount);
    }

    /**
     * @notice Retrieve historical gas estimates for a user
     * @param _user User address to query
     * @param _offset Index to start retrieving from (pagination)
     * @param _limit Maximum number of estimates to return
     * @return estimates Array of GasEstimate structs
     */
    function getGasEstimates(
        address _user,
        uint256 _offset,
        uint256 _limit
    ) external view returns (GasEstimate[] memory estimates) {
        GasEstimate[] memory userEstimates = gasEstimates[_user];
        uint256 length = userEstimates.length;
        
        if (_offset >= length) {
            return new GasEstimate[](0);
        }

        uint256 end = _offset + _limit;
        if (end > length) {
            end = length;
        }

        estimates = new GasEstimate[](end - _offset);
        for (uint256 i = _offset; i < end;) {
            estimates[i - _offset] = userEstimates[i];
            unchecked { ++i; }
        }

        return estimates;
    }

    /**
     * @notice Calculate potential gas savings for a user
     * @dev Based on a simplified 10% savings assumption
     * @param _user User address to calculate savings for
     * @return totalSavings Total estimated gas tokens saved
     * @return averageSavings Average gas saved per transaction
     */
    function calculateGasSavings(address _user) 
        external 
        view 
        returns (uint256 totalSavings, uint256 averageSavings) 
    {
        GasEstimate[] memory userEstimates = gasEstimates[_user];
        uint256 length = userEstimates.length;
        
        if (length == 0) {
            return (0, 0);
        }

        uint256 totalGas = 0;
        for (uint256 i = 0; i < length;) {
            totalGas += userEstimates[i].gasUsed;
            unchecked { ++i; }
        }

        // Simplified calculation - in practice, you'd compare against individual transactions
        totalSavings = totalGas / 10; // Assume 10% savings
        averageSavings = totalSavings / length;

        return (totalSavings, averageSavings);
    }

    /**
     * @dev Emergency pause a contract
     * @param _contract Contract address to pause
     */
    function emergencyPause(address _contract) external onlyOwner {
        if (_contract == address(0)) revert InvalidTarget();
        isPaused[_contract] = true;
        emit EmergencyPause(msg.sender, block.timestamp);
    }

    /**
     * @dev Emergency unpause a contract
     * @param _contract Contract address to unpause
     */
    function emergencyUnpause(address _contract) external onlyOwner {
        if (_contract == address(0)) revert InvalidTarget();
        isPaused[_contract] = false;
        emit EmergencyUnpause(msg.sender, block.timestamp);
    }

    /**
     * @dev Authorize a contract
     * @param _contract Contract address to authorize
     */
    function authorizeContract(address _contract) external onlyOwner {
        if (_contract == address(0)) revert InvalidTarget();
        authorizedContracts[_contract] = true;
        emit ContractAuthorized(_contract);
    }

    /**
     * @dev Revoke contract authorization
     * @param _contract Contract address to revoke
     */
    function revokeContractAuthorization(address _contract) external onlyOwner {
        if (_contract == address(0)) revert InvalidTarget();
        authorizedContracts[_contract] = false;
        emit AuthorizationRevoked(_contract);
    }

    /**
     * @dev Get contract information
     * @param _contract Contract address
     * @return hasCode True if address is a contract
     * @return isAuthorized True if contract is authorized
     * @return _isPaused True if contract is paused
     */
    function getContractInfo(address _contract)
        external
        view
        returns (
            bool hasCode,
            bool isAuthorized,
            bool _isPaused
        )
    {
        uint256 size;
        assembly {
            size := extcodesize(_contract)
        }

        return (
            size > 0,
            authorizedContracts[_contract],
            isPaused[_contract]
        );
    }

    /**
     * @dev Withdraw contract balance (only owner)
     */
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        if (balance == 0) revert NoBalanceToWithdraw();

        (bool success, ) = payable(owner()).call{value: balance}("");
        if (!success) revert TransferFailed();
    }

    /**
     * @dev Withdraw ERC20 tokens (only owner)
     * @param _token Token address
     * @param _amount Amount to withdraw
     */
    function withdrawTokens(address _token, uint256 _amount) external onlyOwner nonReentrant {
        if (_token == address(0)) revert InvalidToken();
        if (_amount == 0) revert InvalidAmount();

        bool success = IERC20(_token).transfer(owner(), _amount);
        if (!success) revert TokenTransferFailed();
    }
}
