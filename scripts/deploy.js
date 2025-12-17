const hre = require("hardhat");
const fs = require('fs');

const DEPLOYMENT_FILE = 'deployment.json';
const BLOCK_CONFIRMATIONS = 5;

async function main() {
  console.log("🚀 Deploying Utilities Contract to Base Sepolia...\n");

  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying with account:", deployer.address);

  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "ETH\n");

  const Contract = await hre.ethers.getContractFactory("Utilities");

  console.log("⏳ Deploying Utilities contract...");
  const contract = await Contract.deploy();

  await contract.waitForDeployment();
  const contractAddress = await contract.getAddress();
  console.log("✅ Utilities deployed to:", contractAddress);

  console.log(`⏳ Waiting for ${BLOCK_CONFIRMATIONS} block confirmations...`);
  const deployTx = contract.deploymentTransaction();
  await deployTx.wait(BLOCK_CONFIRMATIONS);
  console.log("✅ Confirmed!\n");

  const receipt = await deployTx.wait();

  const deploymentInfo = {
    network: "base-sepolia",
    contractName: "Utilities",
    contractAddress: contractAddress,
    deployer: deployer.address,
    chainId: 84532,
    timestamp: new Date().toISOString(),
    blockNumber: receipt.blockNumber,
    transactionHash: receipt.hash,
    gasUsed: receipt.gasUsed.toString(),
    gasPrice: receipt.gasPrice.toString()
  };

  fs.writeFileSync(DEPLOYMENT_FILE, JSON.stringify(deploymentInfo, null, 2));

  console.log(`📄 Deployment info saved to ${DEPLOYMENT_FILE}\n`);
  console.log("═══════════════════════════════════════");
  console.log("🎉 DEPLOYMENT SUCCESSFUL!");
  console.log("═══════════════════════════════════════");
  console.log("Contract:", contractAddress);
  console.log("Gas Used:", receipt.gasUsed.toString());
  console.log("═══════════════════════════════════════\n");

  return contract;
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Deployment failed:", error);
    process.exit(1);
  });
