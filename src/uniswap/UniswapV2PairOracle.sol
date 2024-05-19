// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IOracle } from "../interfaces/IOracle.sol";
import { IUniswapV2Pair } from "./IUniswapV2Pair.sol";
import { IERC20 } from "forge-std/interfaces/IERC20.sol";
import { FixedPointMathLib } from "solmate/utils/FixedPointMathLib.sol";

/**
 * @title Uniswap v2 LP Oracle
 *     @notice Price oracle for uniswap v2 LP Tokens
 */
contract UniswapV2PairOracle is IOracle {
    using FixedPointMathLib for uint256;

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    /// @notice Internal oracle used to fetch ETH prices for pair tokens
    IOracle public immutable ETH_ORACLE;

    constructor(address ethOracle) {
        ETH_ORACLE = IOracle(ethOracle);
    }

    /// @inheritdoc IOracle
    function getQuote(uint256 baseAmount, address base, address quote) external view returns (uint256) {
        if (quote != ETH) revert OracleUnsupportedPair(base, quote);
        uint256 pairSpotPrice = _getSpotPrice(base); // assumes base is a uniswap v2 pair
        return baseAmount.mulWadDown(pairSpotPrice);
    }

    // adapted from https://blog.alphaventuredao.io/fair-lp-token-pricing
    function _getSpotPrice(address pair) internal view returns (uint256) {
        address token0 = IUniswapV2Pair(pair).token0();
        address token1 = IUniswapV2Pair(pair).token1();

        uint256 decimals0 = IERC20(token0).decimals();
        uint256 decimals1 = IERC20(token1).decimals();

        (uint256 r0, uint256 r1,) = IUniswapV2Pair(pair).getReserves();

        r0 = _scaleTo18Decimals(r0, decimals0); // scale r0 to 18 decimals
        r1 = _scaleTo18Decimals(r1, decimals1); // scale r1 to 18 decimals
        uint256 p0 = ETH_ORACLE.getQuote(10 ** decimals0, token0, ETH);
        uint256 p1 = ETH_ORACLE.getQuote(10 ** decimals1, token1, ETH);

        // 2 * sqrt(r0 * r1 * p0 * p1) / totalSupply
        return FixedPointMathLib.sqrt(r0.mulWadDown(r1).mulWadDown(p0).mulWadDown(p1)).mulDivDown(
            2e27, IUniswapV2Pair(pair).totalSupply()
        );
    }

    /// @param val value to be scaled
    /// @param decimals current number of decimals for val
    function _scaleTo18Decimals(uint256 val, uint256 decimals) internal pure returns (uint256) {
        if (decimals <= 18) {
            val = val * 10 ** (18 - decimals);
        } else {
            val = val / 10 ** (decimals - 18);
        }
        return val;
    }
}
