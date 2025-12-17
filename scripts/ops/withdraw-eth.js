const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const tx = await contract.withdraw();
    await tx.wait();
    console.log("Withdrawn ETH to owner");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
