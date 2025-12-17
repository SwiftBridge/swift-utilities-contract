const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const token = "0x0000000000000000000000000000000000000000"; // Replace
    const to = deployment.deployer;
    const amount = hre.ethers.parseEther("10");

    const tx = await contract.transfer(token, to, amount);
    await tx.wait();
    console.log("Transferred Tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
