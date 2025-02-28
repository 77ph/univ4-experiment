
hooks = [
    "BEFORE_INITIALIZE",
    "AFTER_INITIALIZE",
    "BEFORE_MODIFY_POSITION",
    "AFTER_MODIFY_POSITION",
    "BEFORE_SWAP",
    "AFTER_SWAP",
    "BEFORE_DONATE",
    "AFTER_DONATE",
    "BEFORE_SETTLE",
    "AFTER_SETTLE",
    "BEFORE_LOCK",
    "AFTER_LOCK",
    "BEFORE_SYNC",
    "AFTER_SYNC"
]


print(f"{'Bit №':<5} | {'Hook Name':<25} | {'Address'}")
print("-" * 70)
for i, hook in enumerate(hooks):
    address_int = (1 << i)  

    address_hex = f"0x{address_int:040x}"  #40-hex (Ethereum-адрес)
    print(f"{i:<5} | {hook:<25} | {address_hex}")

