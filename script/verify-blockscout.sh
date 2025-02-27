#!/bin/bash

# Загружаем переменные
if [ -f deployed.env ]; then
    export $(grep -v '^#' deployed.env | xargs)
fi

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Проверка наличия необходимых переменных
if [[ -z "$DEPLOYED_CONTRACT" || -z "$SEPOLIA_RPC_URL" || -z "$SCAN_URL" || -z "$ADMIN" || -z "$POSITION_MANAGER" || -z "$POOL_MANAGER" ]]; then
    echo "❌ ERROR: Missing environment variables!"
    exit 1
fi

echo "🔍 Verifying contract $DEPLOYED_CONTRACon  $SCAN_URL ..."

forge verify-contract \
    --chain-id 11155111 \
    --rpc-url $SEPOLIA_RPC_URL \
    --verifier blockscout \
    --verifier-url "$SCAN_URL" /
    --compiler-version 0.8.25
    "$DEPLOYED_CONTRACT" \
    src/UniswapV4LiquidityHelper.sol:UniswapV4LiquidityHelper \
    --constructor-args "$ADMIN" "$POSITION_MANAGER" "$POOL_MANAGER"

if [ $? -eq 0 ]; then
    echo "✅ Contract successfully verified on Etherscan!"
else
    echo "❌ Verification failed!"
fi

