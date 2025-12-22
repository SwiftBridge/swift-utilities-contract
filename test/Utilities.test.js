const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Utilities", function () {
    let utilities;
    let owner;
    let otherAccount;
    let erc20Mock;

    beforeEach(async function () {
        [owner, otherAccount] = await ethers.getSigners();
        const Utilities = await ethers.getContractFactory("Utilities");
        utilities = await Utilities.deploy();
    });

    describe("Gas Estimation", function () {
        it("Should estimate gas for a transaction", async function () {
            const target = otherAccount.address;
            const data = "0x";
            const value = ethers.parseEther("1.0");

            const estimatedGas = await utilities.estimateGas(target, data, value);
            expect(estimatedGas).to.be.gt(21000);
        });

        it("Should revert if target is zero address", async function () {
            const target = ethers.ZeroAddress;
            const data = "0x";
            const value = 0;

            await expect(
                utilities.estimateGas(target, data, value)
            ).to.be.revertedWithCustomError(utilities, "InvalidTarget");
        });
    });

    describe("Batch Execution", function () {
        it("Should execute a batch of operations", async function () {
            const operations = [
                {
                    target: otherAccount.address,
                    data: "0x",
                    value: ethers.parseEther("0.1"),
                    success: false, // ignored in input
                    returnData: "0x" // ignored in input
                },
                {
                    target: otherAccount.address,
                    data: "0x",
                    value: ethers.parseEther("0.2"),
                    success: false,
                    returnData: "0x"
                }
            ];

            await expect(utilities.executeBatch(operations, { value: ethers.parseEther("1.0") })).to.emit(utilities, "BatchProcessed");
        });
    });
});
