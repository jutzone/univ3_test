import { ethers } from "hardhat";
import { expect } from "chai";

describe("UniswapV3PositionManager", function () {
    it("Should deploy the contract correctly", async function () {
        const positionManagerAddress = process.env.UV3_PM_ADDRESS;

        const PositionManager = await ethers.getContractFactory(
            "UniswapV3PositionManager"
        );
        const positionManager = await PositionManager.deploy(
            positionManagerAddress
        );

        await positionManager.waitForDeployment();

        expect(positionManager.address).to.properAddress;
    });

    it("Should calculate tick from price correctly", async function () {
        const positionManagerAddress = process.env.UV3_PM_ADDRESS;

        const PositionManager = await ethers.getContractFactory(
            "UniswapV3PositionManager"
        );
        const positionManager = await PositionManager.deploy(
            positionManagerAddress
        );

        await positionManager.deployed();

        const tick = await positionManager.getTickFromPrice(100000);
        expect(tick).to.be.a("number");
    });

    it("Should reject invalid price", async function () {
        const positionManagerAddress = process.env.UV3_PM_ADDRESS;

        const PositionManager = await ethers.getContractFactory(
            "UniswapV3PositionManager"
        );
        const positionManager = await PositionManager.deploy(
            positionManagerAddress
        );

        await positionManager.deployed();

        await expect(positionManager.getTickFromPrice(0)).to.be.revertedWith(
            "Price must be greater than zero"
        );
    });
});

