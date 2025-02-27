# Таблица хуков
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

# Генерация адресов с установленным соответствующим битом
print(f"{'Bit №':<5} | {'Hook Name':<25} | {'Address'}")
print("-" * 70)
for i, hook in enumerate(hooks):
    address_int = (1 << i)  # Устанавливаем только i-й бит

    address_hex = f"0x{address_int:040x}"  # Форматируем в 40-символьный hex (Ethereum-адрес)
    print(f"{i:<5} | {hook:<25} | {address_hex}")

