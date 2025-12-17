const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    // Dummy data for estimation
    const target = deployment.deployer;
    const data = "0x";
    const value = 0;

    const gas = await contract.estimateGas(target, data, value);
    console.log("Estimated Gas:", gas.toString());
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
