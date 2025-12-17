const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const to = deployment.deployer;
    const amount = hre.ethers.parseEther("0.1");

    // Transfer ETH via contract (requires contract to have balance)
    const tx = await contract.transfer(hre.ethers.ZeroAddress, to, amount);
    await tx.wait();
    console.log("Transferred ETH");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
