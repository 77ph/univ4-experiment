#!/bin/bash

# Загружаем переменные из .env (если есть)
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Проверка наличия переменных
if [[ -z "$PRIVATE_KEY" || -z "$SEPOLIA_RPC_URL" || -z "$ADMIN" || -z "$POSITION_MANAGER" || -z "$POOL_MANAGER" ]]; then
    echo "❌ ERROR: One or more environment variables are missing!"
    exit 1
fi

echo "🚀 Deploying UniswapV4LiquidityHelper to Sepolia..."

# Запускаем Foundry для деплоя
forge create src/UniswapV4LiquidityHelper.sol:UniswapV4LiquidityHelper \
    --constructor-args "$ADMIN" "$POSITION_MANAGER" "$POOL_MANAGER" \
    --rpc-url "$SEPOLIA_RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --etherscan-api-key "$ETHERSCAN_API_KEY" \
    --verify \
    --json | tee deployment.json

# Извлекаем адрес контракта из вывода
DEPLOYED_CONTRACT=$(jq -r '.deployedTo' deployment.json)

if [[ "$DEPLOYED_CONTRACT" == "null" || -z "$DEPLOYED_CONTRACT" ]]; then
    echo "❌ Deployment failed!"
    exit 1
fi

echo "✅ Contract deployed at: $DEPLOYED_CONTRACT"

# Сохранение адреса для верификации
echo "DEPLOYED_CONTRACT=$DEPLOYED_CONTRACT" > deployed.env

echo "💾 Saved contract address to deployed.env"

