const hre = require("hardhat");

async function main() {
    const deployment = require("../../deployment.json");
    const contract = await hre.ethers.getContractAt("UtilitiesV2", deployment.contractAddress);

    const ops = [
        {
            target: deployment.deployer,
            data: "0x",
            value: 0,
            success: false,
            returnData: "0x"
        }
    ];

    console.log("Simulating batch...");
    try {
        await contract.executeBatch.staticCall(ops);
        console.log("Simulation successful");
    } catch (e) {
        console.error("Simulation failed:", e.message);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
