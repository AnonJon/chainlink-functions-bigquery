// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {BigQueryWeather} from "../src/BQWeather.sol";

contract DeployScript is Utils {
    uint256 deployerPrivateKey;
    BigQueryWeather public bqweather;
    uint64 public _subId; // set Chainlink Functions subscription ID

    function run() public {
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);
        bytes memory lambda = getLambda("/lambdas/BigQuery-weather.js");
        bqweather = new BigQueryWeather(getValue("oracle"), 200000, _subId);
        updateDeployment(address(bqweather), "BQWeather");

        bqweather.setFunction(lambda);
        vm.stopBroadcast();
    }

    function getLambda(string memory input) internal view returns (bytes memory) {
        /// @dev Stringify the lambda function
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, input);
        string memory lambda = vm.readFile(path);
        return bytes(lambda);
    }
}
