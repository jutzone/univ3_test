// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract UniswapV3PositionManager {
    INonfungiblePositionManager public immutable positionManager;

    constructor(address _positionManager) {
        positionManager = INonfungiblePositionManager(_positionManager);
    }

    /**
     * @notice Adds liquidity to a Uniswap V3 pool.
     * @param pool The address of the Uniswap V3 pool.
     * @param token0Amount The amount of token0 to add.
     * @param token1Amount The amount of token1 to add.
     * @param width The width parameter as defined in the problem.
     */
    function addLiquidity(
        address pool,
        uint256 token0Amount,
        uint256 token1Amount,
        uint256 width
    ) external {
        IUniswapV3Pool uniswapPool = IUniswapV3Pool(pool);

        address token0 = uniswapPool.token0();
        address token1 = uniswapPool.token1();
        uint24 fee = uniswapPool.fee();

        (uint160 sqrtPriceX96, , , , , , ) = uniswapPool.slot0();
        uint256 currentPrice = (uint256(sqrtPriceX96) * uint256(sqrtPriceX96)) /
            (2 ** 192);

        uint256 lowerPrice = (currentPrice * (10000 - width)) / (10000 + width);
        uint256 upperPrice = (currentPrice * (10000 + width)) / (10000 - width);

        int24 lowerTick = getTickFromPrice(lowerPrice);
        int24 upperTick = getTickFromPrice(upperPrice);

        IERC20(token0).transferFrom(msg.sender, address(this), token0Amount);
        IERC20(token1).transferFrom(msg.sender, address(this), token1Amount);

        IERC20(token0).approve(address(positionManager), token0Amount);
        IERC20(token1).approve(address(positionManager), token1Amount);

        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: fee,
                tickLower: lowerTick,
                tickUpper: upperTick,
                amount0Desired: token0Amount,
                amount1Desired: token1Amount,
                amount0Min: 0,
                amount1Min: 0,
                recipient: msg.sender,
                deadline: block.timestamp
            });

        (uint256 tokenId, , , ) = positionManager.mint(params);

        require(tokenId > 0, "Failed to mint position");
    }

    /**
     * @notice Calculates the tick corresponding to a given price.
     * @param price The price to convert to a tick.
     * @return The tick corresponding to the price.
     */
    function getTickFromPrice(uint256 price) public pure returns (int24) {
        require(price > 0, "Price must be greater than zero");

        uint256 logPrice = log2(price);
        int256 tick = int256((logPrice - 128) * 2);
        require(
            tick >= type(int24).min && tick <= type(int24).max,
            "Tick out of range"
        );

        return int24(tick);
    }

    /**
     * @notice Computes the binary logarithm of a number.
     * @param x The number to compute the log2 of.
     * @return result The binary logarithm of x.
     */
    function log2(uint256 x) public pure returns (uint256 result) {
        require(x > 0, "Input must be positive");
        while (x > 1) {
            x >>= 1;
            result++;
        }
    }
}
