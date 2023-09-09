// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract Utils is Script {
    /**
     * @notice Update the deployment address of a contract in the config.json file
     * @param newAddress The new address of the contract
     * @param key The key of the contract
     */
    function updateDeployment(address newAddress, string memory key) internal {
        string memory inputDir = "script/input/";
        string memory chainDir = string.concat(vm.toString(block.chainid), "/config.json");
        string[] memory inputs = new string[](4);
        inputs[0] = "./update-config.sh";
        inputs[1] = string.concat(inputDir, chainDir);
        inputs[2] = key;
        inputs[3] = vm.toString(newAddress);

        vm.ffi(inputs);
    }

    /**
     * @notice Get the deployment address of a contract in the config.json file
     * @param key The key of the value
     */
    function getValue(string memory key) internal returns (address) {
        string memory inputDir = "script/input/";
        string memory chainDir = string.concat(vm.toString(block.chainid), "/config.json");
        string[] memory inputs = new string[](3);
        inputs[0] = "./get-value.sh";
        inputs[1] = string.concat(inputDir, chainDir);
        inputs[2] = key;

        bytes memory r = vm.ffi(inputs);
        address addr;
        assembly {
            addr := mload(add(r, 20))
        }
        return addr;
    }

    /**
     * @notice Get a string value in the config.json file
     * @param key The key of the value
     */
    function getStringValue(string memory key) internal returns (string memory) {
        string memory inputDir = "script/input/";
        string memory chainDir = string.concat(vm.toString(block.chainid), "/config.json");
        string[] memory inputs = new string[](3);
        inputs[0] = "./get-value.sh";
        inputs[1] = string.concat(inputDir, chainDir);
        inputs[2] = key;

        bytes memory r = vm.ffi(inputs);

        return string(r);
    }
}
