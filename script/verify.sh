#!/bin/bash

# Загружаем переменные
if [ -f deployed.env ]; then
    export $(grep -v '^#' deployed.env | xargs)
fi

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Проверка наличия необходимых переменных
if [[ -z "$DEPLOYED_CONTRACT" || -z "$SEPOLIA_RPC_URL" || -z "$ETHERSCAN_API_KEY" || -z "$ADMIN" || -z "$POSITION_MANAGER" || -z "$POOL_MANAGER" ]]; then
    echo "❌ ERROR: Missing environment variables!"
    exit 1
fi

echo "🔍 Verifying contract $DEPLOYED_CONTRACT on Etherscan..."

forge verify-contract \
    --chain-id 11155111 \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    "$DEPLOYED_CONTRACT" \
    src/UniswapV4LiquidityHelper.sol:UniswapV4LiquidityHelper \
    --constructor-args "$ADMIN" "$POSITION_MANAGER" "$POOL_MANAGER"

if [ $? -eq 0 ]; then
    echo "✅ Contract successfully verified on Etherscan!"
else
    echo "❌ Verification failed!"
fi

