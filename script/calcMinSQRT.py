import math

def sqrt_price_at_tick(tick: int) -> int:
    """Computes the sqrtPriceX96 for a given tick based on Uniswap V3 formulas."""
    sqrt_ratio = math.pow(1.0001, tick / 2)  # Use half tick for correct computation
    sqrt_price_x96 = int(sqrt_ratio * (1 << 96))  # Shift by 2^96 for fixed-point representation
    return sqrt_price_x96

#MIN_TICK = -887272
#MAX_TICK =  887272
MIN_TICK = -887200 
MAX_TICK =  887200

MIN_SQRT_RATIO = sqrt_price_at_tick(MIN_TICK)
MAX_SQRT_RATIO = sqrt_price_at_tick(MAX_TICK)

print(f"MIN_SQRT_RATIO: {MIN_SQRT_RATIO}")
print(f"MAX_SQRT_RATIO: {MAX_SQRT_RATIO}")
