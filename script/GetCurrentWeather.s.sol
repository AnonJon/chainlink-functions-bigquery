// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Utils} from "../src/utils/Utils.sol";
import {BigQueryWeather} from "../src/BQWeather.sol";

contract GetCurrentWeatherScript is Utils {
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
        bqweather.requestWeather(
            "SELECT * FROM bigquery-public-data.noaa_gsod.gsod2023 where stn = '081810' order by date desc limit 1'"
        );

        vm.stopBroadcast();
    }
}
