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

// Константы
const unsigned char DEPLOYER_ADDRESS[20] = {
    0x48, 0x38, 0xB1, 0x06, 0xFC, 0xE9, 0x64, 0x7B, 0xDF, 0x1E, 
    0x78, 0x77, 0xBF, 0x73, 0xCE, 0x8B, 0x0B, 0xAD, 0x5F, 0x97
};
const unsigned char BYTECODE_HASH[32] = {
    0xC0, 0x3E, 0xCA, 0x48, 0xFF, 0xA9, 0x96, 0xBD, 0x8D, 0x5E, 
    0x3B, 0xE4, 0x89, 0x57, 0xEF, 0xDE, 0x5E, 0x1B, 0x3E, 0x6D, 
    0x1D, 0x11, 0x32, 0x3B, 0xC2, 0xF1, 0x8D, 0xD4, 0x03, 0x74, 
    0x44, 0x32
};
const std::string DESIRED_SUFFIX = "2400"; // Последние биты

// Функция преобразования байтов в hex
std::string toHex(const unsigned char* data, size_t length) {
    std::ostringstream oss;
    for (size_t i = 0; i < length; ++i)
        oss << std::hex << std::setw(2) << std::setfill('0') << (int)data[i];
    return oss.str();
}

// Генерация Ethereum-адреса с использованием Keccak256 (SHA3-256)
std::string generateAddress(const std::vector<unsigned char>& salt) {
    std::vector<unsigned char> preimage(1 + 20 + 32 + 32);
    preimage[0] = 0xff;

    // Заполняем preimage
    std::memcpy(preimage.data() + 1, DEPLOYER_ADDRESS, 20);
    std::memcpy(preimage.data() + 21, salt.data(), 32);
    std::memcpy(preimage.data() + 53, BYTECODE_HASH, 32);

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
void findSalt() {
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

            std::string address = generateAddress(localSalt);

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

int main() {
    findSalt();
    return 0;
}

