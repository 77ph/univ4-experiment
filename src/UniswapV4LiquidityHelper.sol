// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "v4-periphery/src/interfaces/IPositionManager.sol";
import "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import "@uniswap/v4-core/src/types/PoolKey.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {LiquidityAmounts} from "v4-periphery/src/libraries/LiquidityAmounts.sol";

interface IPermit2 {
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;
}


contract UniswapV4LiquidityHelper is Ownable {
    using SafeERC20 for IERC20;

    IPositionManager public immutable positionManager;
    IPoolManager public immutable poolManager;
    IPermit2 public constant permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);


    uint24 public constant FEE_TIER = 10_000;
    int24 public constant MIN_TICK = -887200;
    int24 public constant MAX_TICK = -MIN_TICK;

    //uint160 public constant MIN_SQRT_RATIO = 4295128739; // standard Uniswap V3 sqrtRatioAt MIN_TICK
    //uint160 public constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342; // standard Uniswap V3 sqrtRatioAt MAX_TICK

    uint160 public constant MIN_SQRT_RATIO = 4310618291; // -887200 Uniswap V3 sqrtRatioAt MIN_TICK
    uint160 public constant MAX_SQRT_RATIO = 1456195216263841456589366507244248471462712705024; // 887200 Uniswap V3 sqrtRatioAt MAX_TICK

    event PoolCreated(bytes32 poolId);
    event LiquidityAdded(bytes32 poolId, uint256 liquidity);
    event Withdrawal(IERC20 indexed token, uint256 amount);

    constructor(address _admin, address _positionManager, address _poolManager) Ownable(_admin) {
        transferOwnership(_admin);
        positionManager = IPositionManager(_positionManager);
        poolManager = IPoolManager(_poolManager);
    }

    function createUniswapPair(
        address _usdc,
        address _bid,
        uint256 _usdcAmount,
        uint256 _bidAmount,
        address Hook
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
            hooks: IHooks(Hook),
            tickSpacing: 200
        });

        PoolId poolId = PoolIdLibrary.toId(key);
        poolIdBytes = PoolId.unwrap(poolId);

        (uint160 sqrtPriceX96,,,) = StateLibrary.getSlot0(poolManager, poolId);
        if (sqrtPriceX96 > 0) {
            revert("Pool already exists");
        }

        uint160 initialSqrtPriceX96 = _calculatePrice(amount0, amount1);

        poolManager.initialize(key, initialSqrtPriceX96);
        emit PoolCreated(poolIdBytes);

        uint160 sqrtRatioAX96 = MIN_SQRT_RATIO;
        uint160 sqrtRatioBX96 = MAX_SQRT_RATIO;

        liquidity = LiquidityAmounts.getLiquidityForAmounts(
            initialSqrtPriceX96,
            sqrtRatioAX96,
            sqrtRatioBX96,
            amount0,
            amount1
        );

        require(liquidity > 0, "Liquidity must be greater than zero");
        
        IERC20(token0).approve(address(permit2), amount0);
        IERC20(token1).approve(address(permit2), amount1);
        permit2.approve(token0, address(positionManager), uint160(amount0), uint48(block.timestamp + 1 days));
        permit2.approve(token1, address(positionManager), uint160(amount1), uint48(block.timestamp + 1 days));


        bytes memory actions = abi.encodePacked(uint8(Actions.MINT_POSITION), uint8(Actions.SETTLE_PAIR));
        bytes[] memory params = new bytes[](2);

        params[0] = abi.encode(key, MIN_TICK, MAX_TICK, liquidity, amount0, amount1, msg.sender, "");
        params[1] = abi.encode(Currency.wrap(token0), Currency.wrap(token1));

        uint256 deadline = block.timestamp + 6000;

        // address currency0Addr = Currency.unwrap(key.currency0);
        uint256 valueToPass = token0 == address(0) ? amount0 : 0;

        positionManager.modifyLiquidities{value: valueToPass}(
            abi.encode(actions, params),
            deadline
        );

        emit LiquidityAdded(poolIdBytes, liquidity);
    }

    function withdraw(IERC20 _token, uint256 _amount) external onlyOwner {
        require(address(_token) != address(0), "Invalid token address");
        require(_amount > 0, "Amount must be greater than zero");
        require(_token.balanceOf(address(this)) >= _amount, "Insufficient balance");
        _token.safeTransfer(msg.sender, _amount);
        emit Withdrawal(_token, _amount);
    }

    function _calculatePrice(uint256 _amount0, uint256 _amount1) private pure returns (uint160 sqrtPriceX96) {
        uint256 price = (_amount1 << 96) / _amount0;
        sqrtPriceX96 = uint160(price);
    }
}
