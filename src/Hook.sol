// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@uniswap/v4-core/src/interfaces/IHooks.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";

import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

import {CurrencyLibrary, Currency} from "@uniswap/v4-core/src/types/Currency.sol";

import "forge-std/console.sol";

contract RestrictedHook is IHooks {
    bool public pause;
    address public owner;

    event BeforeInitialize(address indexed sender, uint256 sqrtPriceX96);
    event AfterSwap(address tokenOut, uint256 amountOut, uint256 amountFee);

    constructor(address _admin) {
        owner = _admin;
        pause = true;
    }

    function changeOwner(address _owner) external {
        if (owner == address(0) || msg.sender == owner) {
            owner = _owner;
        } else {
            revert("Owner only");
        }
    }

    function setPause(bool flag) external {
        if (msg.sender != owner) {
            revert("Owner only");
        }
        pause = flag;
    }

    function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96) external returns (bytes4) {
        emit BeforeInitialize(sender, sqrtPriceX96);
        return RestrictedHook.beforeInitialize.selector;
    }

    function afterInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, int24 tick)
        external
        returns (bytes4)
    {
        return RestrictedHook.afterInitialize.selector;
    }

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4) {
        if (pause) {
            revert("Paused");
        }
        return RestrictedHook.beforeAddLiquidity.selector;
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        BalanceDelta feesAccrued,
        bytes calldata hookData
    ) external returns (bytes4, BalanceDelta) {
        return (RestrictedHook.afterAddLiquidity.selector, BalanceDelta.wrap(0));
    }

    function beforeRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4) {
        return RestrictedHook.beforeRemoveLiquidity.selector;
    }

    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        BalanceDelta feesAccrued,
        bytes calldata hookData
    ) external returns (bytes4, BalanceDelta) {
        return (RestrictedHook.afterRemoveLiquidity.selector, BalanceDelta.wrap(0));
    }

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external returns (bytes4, BeforeSwapDelta, uint24) {
        return (RestrictedHook.beforeSwap.selector, BeforeSwapDelta.wrap(0), 0);
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4, int128) {
        address tokenOut;
        uint256 amountOut;

        console.log("delta.amount0", int256(delta.amount0()));
        console.log("delta.amount1", int256(delta.amount1()));

        if (params.amountSpecified < 0) {
            // user swaps token0 → receives token1
            tokenOut = Currency.unwrap(key.currency1);
            amountOut = uint256(uint128(-delta.amount1()));
        } else {
            // user swaps token1 → receives token0
            tokenOut = Currency.unwrap(key.currency0);
            amountOut = uint256(uint128(-delta.amount0()));
        }

        uint256 feeBps = 50;
        uint256 feeAmount = (amountOut * feeBps) / 10_000;

        emit AfterSwap(tokenOut, amountOut, feeAmount);

        return (RestrictedHook.afterSwap.selector, 0);
    }

    function beforeDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external returns (bytes4) {
        return RestrictedHook.beforeDonate.selector;
    }

    function afterDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external returns (bytes4) {
        return RestrictedHook.afterDonate.selector;
    }
}
