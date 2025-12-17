const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const target = deployment.contractAddress;
    const isContract = await contract.isContract(target);
    const isPaused = await contract.isPaused(target);

    console.log("Target:", target);
    console.log("Is Contract:", isContract);
    console.log("Is Paused:", isPaused);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
