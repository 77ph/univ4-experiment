import hashlib
import binascii

DEPLOYER_ADDRESS = "0x4838B106FCe9647Bdf1E7877BF73cE8B0BAD5f97"
BYTECODE_HASH = "0xc03eca48ffa996bd8d5e3be48957efde5e1b3e6d1d11323bc2f18dd403744432"
SALT = "953415c933802d62ee0d6d31d2a5cfe7b584376bc6183a1e80f2be8a4d14f185"

# Переводим в байты
preimage = b"\xff" + bytes.fromhex(DEPLOYER_ADDRESS[2:]) + bytes.fromhex(SALT) + bytes.fromhex(BYTECODE_HASH[2:])

# Вычисляем хэш
hash_result = hashlib.sha3_256(preimage).digest()
generated_address = "0x" + binascii.hexlify(hash_result[-20:]).decode()

print(f"Computed Address: {generated_address}")
