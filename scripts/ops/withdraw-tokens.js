const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const token = "0x0000000000000000000000000000000000000000"; // Replace with real token
    const amount = hre.ethers.parseEther("1");

    const tx = await contract.withdrawTokens(token, amount);
    await tx.wait();
    console.log("Withdrawn Tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
