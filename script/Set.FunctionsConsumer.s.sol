// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {BigQueryWeather} from "../src/BQWeather.sol";

interface FunctionsBillingRegistryInterface {
    function addConsumer(uint64 subscriptionId, address consumer) external;
}

contract SetFunctionsConsumerScript is Utils {
    uint256 deployerPrivateKey;
    BigQueryWeather public bqweather;

    function run() public {
        if (block.chainid == 31337) {
            deployerPrivateKey = vm.envUint("ANVIL_PRIVATE_KEY");
        } else {
            deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        }

        vm.startBroadcast(deployerPrivateKey);
        bqweather = BigQueryWeather(getValue("BQWeather"));

        FunctionsBillingRegistryInterface(getValue("functionsRegistry")).addConsumer(0, address(bqweather)); // add your subscription id here

        vm.stopBroadcast();
    }
}
