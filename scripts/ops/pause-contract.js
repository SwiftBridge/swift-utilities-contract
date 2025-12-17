const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    // Pause itself just as a demo, realistically it pauses other contracts
    // But our interface says `emergencyPause(address _contract)`

    const tx = await contract.emergencyPause(deployment.contractAddress);
    await tx.wait();
    console.log("Paused contract:", deployment.contractAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
