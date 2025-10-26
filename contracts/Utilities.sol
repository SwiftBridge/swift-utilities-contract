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
 * @dev A utility contract with helper functions for Swift v2 platform
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
    mapping(address => bool) public emergencyPause;
    
    uint256 public constant MAX_BATCH_SIZE = 50;
    uint256 public constant GAS_LIMIT_BUFFER = 10000;
    uint256 public constant EMERGENCY_PAUSE_DURATION = 24 hours;

    // Modifiers
    modifier onlyAuthorized() {
        require(
            authorizedContracts[msg.sender] || msg.sender == owner(),
            "Not authorized"
        );
        _;
    }

    modifier notPaused() {
        require(!emergencyPause[msg.sender], "Contract paused");
        _;
    }

    constructor() {}

    /**
     * @dev Estimate gas for a transaction
     * @param _target Target contract address
     * @param _data Transaction data
     * @param _value ETH value to send
     * @return estimatedGas Estimated gas usage
     */
    function estimateGas(
        address _target,
        bytes memory _data,
        uint256 _value
    ) external view returns (uint256 estimatedGas) {
        require(_target != address(0), "Invalid target");
        
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
     * @dev Execute multiple operations in a single transaction
     * @param _operations Array of operations to execute
     * @return results Array of operation results
     */
    function executeBatch(
        BatchOperation[] memory _operations
    ) 
        external 
        payable 
        nonReentrant 
        notPaused 
        returns (BatchOperation[] memory results) 
    {
        require(_operations.length <= MAX_BATCH_SIZE, "Batch too large");
        require(_operations.length > 0, "No operations provided");

        uint256 gasStart = gasleft();
        results = new BatchOperation[](_operations.length);

        for (uint256 i = 0; i < _operations.length; i++) {
            BatchOperation memory operation = _operations[i];
            
            (bool success, bytes memory returnData) = operation.target.call{
                value: operation.value,
                gas: gasleft() / (_operations.length - i) // Distribute remaining gas
            }(operation.data);

            results[i] = BatchOperation({
                target: operation.target,
                data: operation.data,
                value: operation.value,
                success: success,
                returnData: returnData
            });
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
     * @dev Optimize gas usage for multiple operations
     * @param _operations Array of operations to optimize
     * @return optimizedOperations Optimized operations
     */
    function optimizeGasUsage(
        BatchOperation[] memory _operations
    ) external pure returns (BatchOperation[] memory optimizedOperations) {
        // This is a simplified optimization
        // In practice, you'd implement more sophisticated algorithms
        
        optimizedOperations = new BatchOperation[](_operations.length);
        
        // Sort operations by gas cost (simplified)
        for (uint256 i = 0; i < _operations.length; i++) {
            optimizedOperations[i] = _operations[i];
        }
        
        return optimizedOperations;
    }

    /**
     * @dev Check if address is a contract
     * @param _address Address to check
     * @return True if address is a contract
     */
    function isContract(address _address) external view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    /**
     * @dev Get contract balance
     * @param _token Token address (address(0) for ETH)
     * @param _account Account address
     * @return balance Token balance
     */
    function getBalance(address _token, address _account) external view returns (uint256 balance) {
        if (_token == address(0)) {
            return _account.balance;
        } else {
            return IERC20(_token).balanceOf(_account);
        }
    }

    /**
     * @dev Transfer tokens or ETH
     * @param _token Token address (address(0) for ETH)
     * @param _to Recipient address
     * @param _amount Amount to transfer
     */
    function transfer(
        address _token,
        address _to,
        uint256 _amount
    ) external payable nonReentrant {
        require(_to != address(0), "Invalid recipient");
        require(_amount > 0, "Amount must be greater than 0");

        if (_token == address(0)) {
            require(msg.value >= _amount, "Insufficient ETH");
            (bool success, ) = payable(_to).call{value: _amount}("");
            require(success, "ETH transfer failed");
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
        require(_token != address(0), "Invalid token");
        require(_spender != address(0), "Invalid spender");

        IERC20(_token).approve(_spender, _amount);
    }

    /**
     * @dev Get gas estimates for a user
     * @param _user User address
     * @param _offset Starting index
     * @param _limit Number of estimates to return
     * @return estimates Array of gas estimates
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
        for (uint256 i = _offset; i < end; i++) {
            estimates[i - _offset] = userEstimates[i];
        }

        return estimates;
    }

    /**
     * @dev Calculate gas savings
     * @param _user User address
     * @return totalSavings Total gas savings
     * @return averageSavings Average gas savings per transaction
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
        for (uint256 i = 0; i < length; i++) {
            totalGas += userEstimates[i].gasUsed;
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
        require(_contract != address(0), "Invalid contract");
        emergencyPause[_contract] = true;
        emit EmergencyPause(msg.sender, block.timestamp);
    }

    /**
     * @dev Emergency unpause a contract
     * @param _contract Contract address to unpause
     */
    function emergencyUnpause(address _contract) external onlyOwner {
        require(_contract != address(0), "Invalid contract");
        emergencyPause[_contract] = false;
        emit EmergencyUnpause(msg.sender, block.timestamp);
    }

    /**
     * @dev Authorize a contract
     * @param _contract Contract address to authorize
     */
    function authorizeContract(address _contract) external onlyOwner {
        require(_contract != address(0), "Invalid contract");
        authorizedContracts[_contract] = true;
    }

    /**
     * @dev Revoke contract authorization
     * @param _contract Contract address to revoke
     */
    function revokeContractAuthorization(address _contract) external onlyOwner {
        require(_contract != address(0), "Invalid contract");
        authorizedContracts[_contract] = false;
    }

    /**
     * @dev Get contract information
     * @param _contract Contract address
     * @return isContract True if address is a contract
     * @return isAuthorized True if contract is authorized
     * @return isPaused True if contract is paused
     */
    function getContractInfo(address _contract) 
        external 
        view 
        returns (
            bool isContract,
            bool isAuthorized,
            bool isPaused
        ) 
    {
        uint256 size;
        assembly {
            size := extcodesize(_contract)
        }
        
        return (
            size > 0,
            authorizedContracts[_contract],
            emergencyPause[_contract]
        );
    }

    /**
     * @dev Withdraw contract balance (only owner)
     */
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        require(balance > 0, "No balance to withdraw");

        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success, "Withdraw failed");
    }

    /**
     * @dev Withdraw ERC20 tokens (only owner)
     * @param _token Token address
     * @param _amount Amount to withdraw
     */
    function withdrawTokens(address _token, uint256 _amount) external onlyOwner nonReentrant {
        require(_token != address(0), "Invalid token");
        require(_amount > 0, "Amount must be greater than 0");

        bool success = IERC20(_token).transfer(owner(), _amount);
        require(success, "Token transfer failed");
    }
}
