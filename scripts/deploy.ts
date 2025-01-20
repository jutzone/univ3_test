import { ethers } from "hardhat";

async function main() {
    const positionManagerAddress = process.env.UV3_PM_ADDRESS;
    console.log("Deploying contract...");

    const PositionManager = await ethers.getContractFactory(
        "UniswapV3PositionManager"
    );
    const positionManager = await PositionManager.deploy(
        positionManagerAddress
    );

    await positionManager.waitForDeployment();

    console.log(
        "UniswapV3PositionManager deployed to:",
        positionManager.address
    );
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

