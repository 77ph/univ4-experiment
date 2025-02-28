// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/interfaces/IHooks.sol";
import "@uniswap/v4-core/src/interfaces/callback/IUnlockCallback.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";

contract UniswapV4LiquidityHelperCore is Ownable, IUnlockCallback {
    using SafeERC20 for IERC20;
    using StateLibrary for IPoolManager;

    uint24 public constant FEE_TIER = 10_000;
    int24 public constant MIN_TICK = -887200;
    int24 public constant MAX_TICK = -MIN_TICK;

    IPoolManager public immutable poolManager;

    event PoolCreated(bytes32 poolId);
    event LiquidityAdded(bytes32 poolId, uint256 liquidity);
    event Withdrawal(IERC20 indexed token, uint256 amount);

    constructor(address _admin, address _poolManager) Ownable(_admin) {
        transferOwnership(_admin);
        poolManager = IPoolManager(_poolManager);
    }

    function createUniswapPair(
        address _usdc,
        address _bid,
        uint256 _usdcAmount,
        uint256 _bidAmount
    ) external onlyOwner returns (bytes32 poolIdBytes, uint256 liquidity) {
        IERC20(_usdc).safeTransferFrom(msg.sender, address(this), _usdcAmount);
        IERC20(_bid).safeTransferFrom(msg.sender, address(this), _bidAmount);

        bool isUSDCFirst = _usdc < _bid;
        (address token0, address token1, uint256 amount0, uint256 amount1) = isUSDCFirst
            ? (_usdc, _bid, _usdcAmount, _bidAmount)
            : (_bid, _usdc, _bidAmount, _usdcAmount);

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(token0),
            currency1: Currency.wrap(token1),
            fee: FEE_TIER,
            hooks: IHooks(address(0)),
            tickSpacing: 200
        });

        PoolId poolId = PoolIdLibrary.toId(key);
        poolIdBytes = PoolId.unwrap(poolId);

        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(poolId);
        if (sqrtPriceX96 > 0) {
            revert("Pool already exists");
        }

        uint160 initialSqrtPriceX96 = _calculatePrice(amount0, amount1);

        int24 initialTick = poolManager.initialize(key, initialSqrtPriceX96);
        emit PoolCreated(poolIdBytes);

        IERC20(token0).approve(address(poolManager), amount0);
        IERC20(token1).approve(address(poolManager), amount1);

        IPoolManager.ModifyLiquidityParams memory params = IPoolManager.ModifyLiquidityParams({
            tickLower: MIN_TICK,
            tickUpper: MAX_TICK,
            liquidityDelta: int256(amount0 + amount1),
            salt: 0
        });

        bytes memory unlockData = abi.encode(key, params);

        bytes memory result = poolManager.unlock(unlockData);

        (BalanceDelta callerDelta,) = abi.decode(result, (BalanceDelta, BalanceDelta));

        liquidity = uint256(int256(callerDelta.amount0()) + int256(callerDelta.amount1()));

        emit LiquidityAdded(poolIdBytes, liquidity);
    }

    function unlockCallback(bytes calldata data) external override returns (bytes memory) {
        require(msg.sender == address(poolManager), "Unauthorized");

        (PoolKey memory key, IPoolManager.ModifyLiquidityParams memory params) = abi.decode(
            data,
            (PoolKey, IPoolManager.ModifyLiquidityParams)
        );

        address token0 = Currency.unwrap(key.currency0);
        address token1 = Currency.unwrap(key.currency1);

        uint256 amount0 = uint256(params.liquidityDelta);
        uint256 amount1 = uint256(params.liquidityDelta);

        IERC20(token0).approve(address(poolManager), amount0);
        IERC20(token1).approve(address(poolManager), amount1);

        (BalanceDelta callerDelta, BalanceDelta feesAccrued) = poolManager.modifyLiquidity(
            key,
            params,
            ""
        );

        poolManager.settle();
        return abi.encode(callerDelta, feesAccrued);
    }

    function withdraw(IERC20 _token, uint256 _amount) external onlyOwner {
        require(address(_token) != address(0), "Invalid token address");
        require(_amount > 0, "Amount must be greater than zero");
        require(_token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        _token.safeTransfer(msg.sender, _amount);
        emit Withdrawal(_token, _amount);
    }

    function _calculatePrice(
    uint256 _amount0,
    uint256 _amount1
    ) private pure returns (uint160 sqrtPriceX96) {
        uint256 price = (_amount1 << 96) / _amount0;
        sqrtPriceX96 = uint160(price);
    }
}



