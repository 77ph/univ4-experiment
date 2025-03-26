// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Commands} from "../lib/universal-router/contracts/libraries/Commands.sol";

/// @notice Минимальный интерфейс самого UniversalRouter
interface IUniversalRouter {
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
}

/// @title MyV4OnlyUniversalRouter
/// @notice Минимальный Universal Router только для Uniswap v4 команд
contract MyV4OnlyUniversalRouter {
    address public immutable v4Router;

    constructor(address _v4Router) {
        v4Router = _v4Router;
    }

    /// @notice Выполняет Uniswap v4 команды
    /// @param commands packed commands
    /// @param inputs calldata inputs (перекодированные)
    /// @param deadline until which the execution is valid
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable {
        IUniversalRouter(v4Router).execute(commands, inputs, deadline);
    }
}
