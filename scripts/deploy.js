const hre = require("hardhat");
const fs = require('fs');

async function main() {
  console.log("🚀 Deploying Utilities Contract to Base Mainnet...\n");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying with account:", deployer.address);

  // Check balance
  const balance = await deployer.getBalance();
  console.log("💰 Account balance:", hre.ethers.utils.formatEther(balance), "ETH\n");

  // Deploy Utilities contract
  const Utilities = await hre.ethers.getContractFactory("Utilities");

  console.log("⏳ Deploying Utilities contract...");
  const utilities = await Utilities.deploy();

  await utilities.deployed();
  console.log("✅ Utilities deployed to:", utilities.address);

  // Wait for block confirmations
  console.log("⏳ Waiting for 5 block confirmations...");
  await utilities.deployTransaction.wait(5);
  console.log("✅ Confirmed!\n");

  // Get deployment info
  const receipt = await utilities.deployTransaction.wait();

  // Save deployment info
  const deploymentInfo = {
    network: "base-mainnet",
    contractName: "Utilities",
    contractAddress: utilities.address,
    deployer: deployer.address,
    chainId: 8453,
    timestamp: new Date().toISOString(),
    blockNumber: receipt.blockNumber,
    transactionHash: receipt.transactionHash,
    gasUsed: receipt.gasUsed.toString(),
    gasPrice: receipt.effectiveGasPrice.toString()
  };

  // Save to file
  fs.writeFileSync(
    'deployment.json',
    JSON.stringify(deploymentInfo, null, 2)
  );

  console.log("📄 Deployment info saved to deployment.json\n");

  console.log("═══════════════════════════════════════");
  console.log("🎉 DEPLOYMENT SUCCESSFUL!");
  console.log("═══════════════════════════════════════");
  console.log("Contract:", utilities.address);
  console.log("Gas Used:", receipt.gasUsed.toString());
  console.log("═══════════════════════════════════════\n");

  console.log("📋 Next steps:");
  console.log("1. Verify contract:");
  console.log(`   npx hardhat verify --network base ${utilities.address}`);
  console.log("\n2. Update frontend with contract address");
  console.log("\n3. Authorize other contracts to interact with Utilities");

  return utilities;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
