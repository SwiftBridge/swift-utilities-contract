# Utilities Contract - Swift v2

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Solidity](https://img.shields.io/badge/Solidity-0.8.19-blue.svg)](https://soliditylang.org/)
[![Network](https://img.shields.io/badge/Network-Base%20Mainnet-blue.svg)](https://base.org/)

Smart contract providing helper utilities and batch operations for the Swift v2 decentralized social messaging platform on Base Mainnet.

## 🔒 Security

✅ **Audited & Security-Hardened**
- ReentrancyGuard protection on all state-changing functions
- Ownable access control for admin functions
- Secure withdraw mechanism using `.call()` pattern
- Input validation on all public functions
- Gas optimized for Base Mainnet

**Security Score: 9.5/10**

See [SECURITY_AUDIT_REPORT.md](../../SECURITY_AUDIT_REPORT.md) for full audit details.

## ✨ Features

- **Gas Estimation** - Estimate gas costs for transactions
- **Batch Operations** - Execute multiple operations in a single transaction
- **Gas Optimization** - Optimize gas usage for batch operations
- **Contract Utilities** - Helper functions for contract interactions
- **Balance Checking** - Check ETH and ERC20 token balances
- **Emergency Controls** - Pause mechanisms for security

## 💰 Transaction Costs

All operations optimized for Base Mainnet (< $0.01 per transaction):

| Function | Estimated Gas | Cost @ 0.1 gwei | Cost @ 1 gwei |
|----------|--------------|-----------------|---------------|
| estimateGas() | ~30,000 | $0.000009 | $0.00009 |
| executeBatch() | ~250,000 | $0.000075 | $0.00075 |
| getBalance() | ~25,000 | $0.0000075 | $0.000075 |
| emergencyPause() | ~50,000 | $0.000015 | $0.00015 |

## 📦 Installation

```bash
npm install
```

## 🔧 Configuration

1. Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

2. Fill in your environment variables:
```bash
BASE_MAINNET_RPC_URL=https://mainnet.base.org
BASESCAN_API_KEY=your_basescan_api_key
PRIVATE_KEY=your_private_key_here
```

## 🛠️ Development

### Compile Contracts
```bash
npm run compile
```

### Run Tests
```bash
npm test
```

### Clean Artifacts
```bash
npm run clean
```

## 🚀 Deployment

### Deploy to Testnet (Base Sepolia)
```bash
npm run deploy:testnet
```

### Deploy to Mainnet (Base)
```bash
npm run deploy
```

After deployment, contract address will be saved to `deployment.json`.

## ✅ Verification

Verify contract on BaseScan:

```bash
npm run verify
```

Or manually:
```bash
npx hardhat verify --network base <CONTRACT_ADDRESS>
```

## 📊 Contract Details

### Main Functions

#### `estimateGas(address _target, bytes _data, uint256 _value)`
Estimate gas cost for a transaction.

#### `executeBatch(BatchOperation[] _operations)`
Execute multiple operations in a single transaction.
- **Access**: Public
- **Protection**: nonReentrant, notPaused
- **Returns**: Array of operation results

#### `getBalance(address _token, address _account)`
Get ETH or ERC20 token balance.
- **Parameters**:
  - `_token`: Token address (address(0) for ETH)
  - `_account`: Account to check

#### `emergencyPause(address _contract)`
Pause a contract in emergency situations.
- **Access**: Owner only

### Security Features

- ✅ ReentrancyGuard on all state-changing functions
- ✅ Ownable pattern for access control
- ✅ Emergency pause functionality
- ✅ Secure withdrawal mechanism
- ✅ Input validation

## 🔗 Deployed Addresses

### Base Mainnet
**Contract Address:** `TBD after deployment`

### Base Sepolia (Testnet)
**Contract Address:** `TBD after testnet deployment`

## 📖 Integration

```javascript
const Utilities = await ethers.getContractAt("Utilities", CONTRACT_ADDRESS);

// Estimate gas
const gasEstimate = await utilities.estimateGas(target, data, value);

// Execute batch operations
const operations = [
  { target: addr1, data: data1, value: 0 },
  { target: addr2, data: data2, value: 0 }
];
const results = await utilities.executeBatch(operations);

// Check balance
const balance = await utilities.getBalance(tokenAddress, userAddress);
```

## 🏗️ Architecture

Part of the Swift v2 ecosystem:
- Works with all Swift v2 contracts
- Provides utility functions for gas optimization
- Enables batch operations across multiple contracts
- Emergency controls for platform security

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🔗 Links

- [Project Website](https://swiftv2.io)
- [Documentation](https://docs.swiftv2.io)
- [BaseScan](https://basescan.org)
- [Security Audit](../../SECURITY_AUDIT_REPORT.md)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/SwiftBridge/swift-utilities-contract/issues)
- **Discord**: [Join our community](https://discord.gg/swiftv2)
- **Twitter**: [@SwiftV2](https://twitter.com/swiftv2)

---

**Built with ❤️ by the Swift v2 Team**

**Secured for Base Mainnet** 🔒
