// SPDX-License-Identifier: MIT
pragma solidity =0.8.26;

import "forge-std/Test.sol";
import "../src/UniswapV4LiquidityHelper.sol";
import "../src/mocks/MockERC20.sol";
import "../src/Hook.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract UniswapV4ForkTest is Test {
    UniswapV4LiquidityHelper liquidityHelper;
    MockERC20 bidMock; // Мок-токен BID
    MockERC20 usdcMock; // Мок-токен USDC
    RestrictedHook restrictedHook;

    address payable constant ALL_HOOKS = payable(0x0000000000000000000000000000000000003fFF);

    address owner = address(this);
    address BNB_POOL_MANAGER = 0x28e2Ea090877bF75740558f6BFB36A5ffeE9e9dF;
    address BNB_POSITION_MANAGER = 0x7A4a5c919aE2541AeD11041A1AEeE68f1287f95b;

    function setUp() public {
        // 1️⃣ Форкаем BNB Chain
        string memory BNB_RPC = "https://bsc-dataseed.binance.org/";
        vm.createSelectFork(BNB_RPC);

        // 2️⃣ Разворачиваем mock USDT
        usdcMock = new MockERC20("Mock USDT", "mUSDT", 18);
        usdcMock.mint(owner, 1_000_000 * 10**18);

        // 3️⃣ Разворачиваем mock BID
        bidMock = new MockERC20("Mock BID", "mBID", 18);
        bidMock.mint(owner, 1_000_000 * 10**18);

        // 4 Разворачиваем контракт UniswapV4LiquidityHelper
        liquidityHelper = new UniswapV4LiquidityHelper(owner, BNB_POSITION_MANAGER, BNB_POOL_MANAGER);

        RestrictedHook impl = new RestrictedHook(owner);
        vm.etch(ALL_HOOKS, address(impl).code);
        restrictedHook = RestrictedHook(ALL_HOOKS);

        restrictedHook.changeOwner(owner);
        restrictedHook.setPause(true);
        bool pause = restrictedHook.pause();
        assertEq(pause, true, "Pause should be true");

        // 5 Даем контракту разрешение на токены
        usdcMock.approve(address(liquidityHelper), type(uint256).max);
        bidMock.approve(address(liquidityHelper), type(uint256).max);
    }

    function testCreateUniswapPair() public {
        uint256 usdcAmount = 1000 * 1e18;
        uint256 bidAmount = 1000 * 1e18;

        // 6️⃣ Получаем баланс владельца перед тестом
        uint256 balanceBefore = usdcMock.balanceOf(owner);

        // Unpaused
        restrictedHook.setPause(false);

        // 7️⃣ Дёргаем контракт на создание пула ликвидности
        (bytes32 poolId, uint256 liquidity) = liquidityHelper.createUniswapPair(
            address(usdcMock), // Используем Mock USDT
            address(bidMock),
            usdcAmount,
            bidAmount,
            address(restrictedHook)
        );

        // 8️⃣ Проверяем, что ликвидность добавлена
        assertGt(liquidity, 0, "Liquidity should be greater than 0");

        // 9️⃣ Проверяем, что баланс владельца изменился
        uint256 balanceAfter = usdcMock.balanceOf(owner);
        assertEq(balanceBefore - balanceAfter, usdcAmount, "Balance should decrease by USDC amount");
    }
}

