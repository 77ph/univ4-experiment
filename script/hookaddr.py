import hashlib
import random
import binascii
from eth_utils import to_checksum_address

DEPLOYER_ADDRESS = "0xYourDeployerAddress"  # Адрес контракта Create2Deployer
BYTECODE_HASH = "0x..."  # Keccak-256 от байткода контракта IHooks
DESIRED_SUFFIX = "2400"  # Последние биты, которые нужно получить

def find_salt():
    while True:
        salt = random.getrandbits(256).to_bytes(32, 'big')
        preimage = b"\xff" + bytes.fromhex(DEPLOYER_ADDRESS[2:]) + salt + bytes.fromhex(BYTECODE_HASH[2:])
        addr = hashlib.sha3_256(preimage).digest()[-20:]
        address = to_checksum_address("0x" + binascii.hexlify(addr).decode())

        if address[-len(DESIRED_SUFFIX):] == DESIRED_SUFFIX:
            print(f"Found salt: {binascii.hexlify(salt).decode()}")
            print(f"Generated address: {address}")
            return binascii.hexlify(salt).decode()

find_salt()

