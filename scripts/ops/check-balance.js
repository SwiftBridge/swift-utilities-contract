const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const balance = await hre.ethers.provider.getBalance(deployment.contractAddress);
    console.log("Contract Balance:", hre.ethers.formatEther(balance), "ETH");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
