#include <iostream>
#include <iomanip>
#include <openssl/evp.h>  
#include <random>
#include <sstream>
#include <omp.h>
#include <vector>
#include <cstring>
#include <atomic>

std::atomic<bool> found(false);  // Глобальная переменная для выхода
std::string DESIRED_SUFFIX = "2400"; // Последние биты

// Функция преобразования байтов в hex
std::string toHex(const unsigned char* data, size_t length) {
    std::ostringstream oss;
    for (size_t i = 0; i < length; ++i)
        oss << std::hex << std::setw(2) << std::setfill('0') << (int)data[i];
    return oss.str();
}

// Функция конвертации строки hex в массив байтов
std::vector<unsigned char> hexToBytes(const std::string& hex) {
    std::vector<unsigned char> bytes;
    for (size_t i = 0; i < hex.length(); i += 2) {
        std::string byteString = hex.substr(i, 2);
        unsigned char byte = static_cast<unsigned char>(std::stoi(byteString, nullptr, 16));
        bytes.push_back(byte);
    }
    return bytes;
}

// Генерация Ethereum-адреса с использованием Keccak256 (SHA3-256)
std::string generateAddress(const std::vector<unsigned char>& deployerAddress, const std::vector<unsigned char>& bytecodeHash, const std::vector<unsigned char>& salt) {
    std::vector<unsigned char> preimage(1 + 20 + 32 + 32);
    preimage[0] = 0xff;

    // Заполняем preimage
    std::memcpy(preimage.data() + 1, deployerAddress.data(), 20);
    std::memcpy(preimage.data() + 21, salt.data(), 32);
    std::memcpy(preimage.data() + 53, bytecodeHash.data(), 32);

    unsigned char hash[32];  // SHA3-256 всегда 32 байта
    unsigned int hash_len = 0;

    EVP_MD_CTX* mdctx = EVP_MD_CTX_new();
    EVP_DigestInit_ex(mdctx, EVP_sha3_256(), nullptr);
    EVP_DigestUpdate(mdctx, preimage.data(), preimage.size());
    EVP_DigestFinal_ex(mdctx, hash, &hash_len);
    EVP_MD_CTX_free(mdctx);

    // Последние 20 байт от SHA3-256 хэша
    std::string address = toHex(hash + 12, 20);
    return address;
}

// Поиск соли
void findSalt(const std::vector<unsigned char>& deployerAddress, const std::vector<unsigned char>& bytecodeHash) {
    std::vector<unsigned char> salt(32);
    std::random_device rd;

    #pragma omp parallel
    {
        std::mt19937 gen(rd());
        std::uniform_int_distribution<int> dist(0, 255);
        std::vector<unsigned char> localSalt(32);

        while (!found.load()) {  // Проверяем глобальный флаг
            for (int i = 0; i < 32; ++i) 
                localSalt[i] = static_cast<unsigned char>(dist(gen));

            std::string address = generateAddress(deployerAddress, bytecodeHash, localSalt);

            if (address.substr(address.length() - DESIRED_SUFFIX.length()) == DESIRED_SUFFIX) {
                #pragma omp critical
                {
                    found.store(true);  // Устанавливаем флаг завершения
                    std::cout << "Found salt: " << toHex(localSalt.data(), 32) << std::endl;
                    std::cout << "Generated address: " << address << std::endl;
                }
                break;  // Выход из цикла для данного потока
            }
        }
    }
}

int main(int argc, char* argv[]) {
    if (argc < 3) {
        std::cerr << "Usage: " << argv[0] << " <DEPLOYER_ADDRESS> <BYTECODE_HASH> [DESIRED_SUFFIX]" << std::endl;
        return 1;
    }

    std::string deployerAddressHex = argv[1];
    std::string bytecodeHashHex = argv[2];

    if (argc > 3) {
        DESIRED_SUFFIX = argv[3];  // Позволяет задавать нужный суффикс через аргументы
    }

    // Проверяем корректность ввода
    if (deployerAddressHex.length() != 40 || bytecodeHashHex.length() != 64) {
        std::cerr << "Error: DEPLOYER_ADDRESS must be 40 hex chars and BYTECODE_HASH must be 64 hex chars." << std::endl;
        return 1;
    }

    std::vector<unsigned char> deployerAddress = hexToBytes(deployerAddressHex);
    std::vector<unsigned char> bytecodeHash = hexToBytes(bytecodeHashHex);

    findSalt(deployerAddress, bytecodeHash);
    return 0;
}

