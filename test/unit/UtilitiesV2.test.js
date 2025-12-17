const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UtilitiesV2 Integration", function () {
    let utilities;
    let owner;
    let otherAccount;

    beforeEach(async function () {
        [owner, otherAccount] = await ethers.getSigners();
        const UtilitiesV2 = await ethers.getContractFactory("UtilitiesV2");
        utilities = await UtilitiesV2.deploy();
    });

    describe("Gas Estimation", function () {
        it("Should estimate gas for a simple transaction", async function () {
            const estimated = await utilities.estimateGas(otherAccount.address, "0x", 0);
            expect(estimated).to.be.gt(21000);
        });

        it("Should revert on invalid target", async function () {
            await expect(
                utilities.estimateGas(ethers.ZeroAddress, "0x", 0)
            ).to.be.revertedWithCustomError(utilities, "InvalidTarget");
        });
    });

    describe("Access Control", function () {
        it("Should set owner correctly", async function () {
            expect(await utilities.owner()).to.equal(owner.address);
        });
    });
});
