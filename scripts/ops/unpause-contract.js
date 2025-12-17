const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const tx = await contract.emergencyUnpause(deployment.contractAddress);
    await tx.wait();
    console.log("Unpaused contract:", deployment.contractAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
