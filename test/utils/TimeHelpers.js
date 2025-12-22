const { ethers } = require("hardhat");

const increaseTime = async (seconds) => {
    await ethers.provider.send("evm_increaseTime", [seconds]);
    await ethers.provider.send("evm_mine");
};

const setTime = async (timestamp) => {
    await ethers.provider.send("evm_setNextBlockTimestamp", [timestamp]);
    await ethers.provider.send("evm_mine");
};

const getBlockTimestamp = async () => {
    const block = await ethers.provider.getBlock("latest");
    return block.timestamp;
};

module.exports = {
    increaseTime,
    setTime,
    getBlockTimestamp,
};
