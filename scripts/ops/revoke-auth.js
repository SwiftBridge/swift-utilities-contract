const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const target = "0x0000000000000000000000000000000000000001";

    const tx = await contract.revokeContractAuthorization(target);
    await tx.wait();
    console.log("Revoked authorization for:", target);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
