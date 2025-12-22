const hre = require("hardhat");

async function main() {
    console.log("Verifying network connection...");

    const network = await hre.ethers.provider.getNetwork();
    console.log(`Connected to network: ${network.name} (Chain ID: ${network.chainId})`);

    const blockNumber = await hre.ethers.provider.getBlockNumber();
    console.log(`Current Block Number: ${blockNumber}`);

    const feeData = await hre.ethers.provider.getFeeData();
    console.log(`Gas Price: ${hre.ethers.formatUnits(feeData.gasPrice || 0, "gwei")} gwei`);

    if (feeData.lastBaseFeePerGas) {
        console.log(`Base Fee: ${hre.ethers.formatUnits(feeData.lastBaseFeePerGas, "gwei")} gwei`);
    }

    const [signer] = await hre.ethers.getSigners();
    if (signer) {
        const balance = await hre.ethers.provider.getBalance(signer.address);
        console.log(`Deployer Account (${signer.address}) Balance: ${hre.ethers.formatEther(balance)} ETH`);
    } else {
        console.log("No signers configured.");
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
