// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Create2Deployer {
    event Deployed(address contractAddress);

    function deploy(bytes32 salt, bytes memory bytecode) external returns (address) {
        address deployedAddress;
        assembly {
            deployedAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(deployedAddress != address(0), "Create2: Failed to deploy");

        emit Deployed(deployedAddress);
        return deployedAddress;
    }

    function computeAddress(bytes32 salt, bytes memory bytecode) external view returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode)))))
        );
    }
}
