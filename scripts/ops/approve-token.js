const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const token = "0x0000000000000000000000000000000000000000"; // Replace
    const spender = deployment.deployer;
    const amount = hre.ethers.parseEther("100");

    const tx = await contract.approve(token, spender, amount);
    await tx.wait();
    console.log("Approved tokens");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
