## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

### TEST
```
forge test --fork-url https://bsc-dataseed.binance.org/ -vvvv
```
### Hook calls
```
forge test --fork-url https://bsc-dataseed.binance.org/ -vvvv | grep 0x0000000000000000000000000000000000003fFF
    ├─ [612487] UniswapV4LiquidityHelper::createUniswapPair(MockERC20: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], MockERC20: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], 1000000000000000000000 [1e21], 1000000000000000000000 [1e21],0x0000000000000000000000000000000000003fFF)
    │   ├─ [33568] 0x28e2Ea090877bF75740558f6BFB36A5ffeE9e9dF::initialize(PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), 79228162514264337593543950336 [7.922e28])
    │   │   ├─ [2035] 0x0000000000000000000000000000000000003fFF::beforeInitialize(UniswapV4LiquidityHelper: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), 79228162514264337593543950336 [7.922e28])
    │   │   ├─ emit Initialize(id: 0xe54f16aef8551f38071585a631177e07dd0456dea435a45f9f0bf01d6daae9a7, currency0: MockERC20: [0x2e234DAe75C793f67A35089C9d99245E1C58470b], currency1: MockERC20: [0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f], fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF, sqrtPriceX96: 79228162514264337593543950336 [7.922e28], tick: 0)
    │   │   ├─ [464] 0x0000000000000000000000000000000000003fFF::afterInitialize(UniswapV4LiquidityHelper: [0xF62849F9A0B5Bf2913b396098F7c7019b51A820a], PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), 79228162514264337593543950336 [7.922e28], 0)
    │   │   │   │   ├─ [169940] 0x28e2Ea090877bF75740558f6BFB36A5ffeE9e9dF::modifyLiquidity(PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), ModifyLiquidityParams({ tickLower: -887200 [-8.872e5], tickUpper: 887200 [8.872e5], liquidityDelta: 1000000000000000000054 [1e21], salt: 0x0000000000000000000000000000000000000000000000000000000000000880 }), 0x)
    │   │   │   │   │   ├─ [2650] 0x0000000000000000000000000000000000003fFF::beforeAddLiquidity(0x7A4a5c919aE2541AeD11041A1AEeE68f1287f95b, PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), ModifyLiquidityParams({ tickLower: -887200 [-8.872e5], tickUpper: 887200 [8.872e5], liquidityDelta: 1000000000000000000054 [1e21], salt: 0x0000000000000000000000000000000000000000000000000000000000000880 }), 0x)
    │   │   │   │   │   ├─ [713] 0x0000000000000000000000000000000000003fFF::afterAddLiquidity(0x7A4a5c919aE2541AeD11041A1AEeE68f1287f95b, PoolKey({ currency0: 0x2e234DAe75C793f67A35089C9d99245E1C58470b, currency1: 0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, fee: 10000 [1e4], tickSpacing: 200, hooks: 0x0000000000000000000000000000000000003fFF }), ModifyLiquidityParams({ tickLower: -887200 [-8.872e5], tickUpper: 887200 [8.872e5], liquidityDelta: 1000000000000000000054 [1e21], salt: 0x0000000000000000000000000000000000000000000000000000000000000880 }), -340282366920938463463034325064847272993536625392568231788544 [-3.402e59], 0, 0x)
```

### Optimized version find_salt
```
sudo apt update
sudo apt install libssl-dev
g++ -o find_salt find_salt.cpp -O2 -fopenmp -lssl -lcrypto

./find_salt 
Found salt: 953415c933802d62ee0d6d31d2a5cfe7b584376bc6183a1e80f2be8a4d14f185
Generated address: 7e7f71aee420c4c89f8e77b4a52fd24bf8042400

Verify:
nano check_find_salt.py
edit
SALT = "953415c933802d62ee0d6d31d2a5cfe7b584376bc6183a1e80f2be8a4d14f185"
python3 check_find_salt.py
Computed Address: 0x7e7f71aee420c4c89f8e77b4a52fd24bf8042400
0x7e7f71aee420c4c89f8e77b4a52fd24bf8042400 == 7e7f71aee420c4c89f8e77b4a52fd24bf8042400
```
