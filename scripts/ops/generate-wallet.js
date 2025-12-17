const { ethers } = require("ethers");

async function main() {
    const wallet = ethers.Wallet.createRandom();
    console.log("New Wallet Generated:");
    console.log("Address:", wallet.address);
    console.log("Private Key:", wallet.privateKey);
    console.log("Mnemonic:", wallet.mnemonic.phrase);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
