// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {FunctionsClient, Functions} from "@chainlink/src/v0.8/functions/dev/0_0_0/FunctionsClient.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IBigQueryWeather} from "./interfaces/IBQWeather.sol";

contract BigQueryWeather is IBigQueryWeather, FunctionsClient, Ownable {
    using Functions for Functions.Request;

    bytes public latestError;
    bytes public lambdaFunction;
    bytes public lambdaSecrets;
    bytes public res;
    uint32 public gasLimit;
    uint64 private subId;
    bytes32 public latestRequestId;

    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    constructor(address _oracle, uint32 _gasLimit, uint64 _subId) FunctionsClient(_oracle) {
        gasLimit = _gasLimit;
        subId = _subId;
    }

    /**
     * @notice Allows the user to call the BigQuery NOAA_GSOD table to get the weather for a given station and date
     * @param _query The SQL query to be executed
     * @dev The query should return a single row and column of data
     */
    function requestWeather(string memory _query) external onlyOwner {
        Functions.Request memory req;
        req.initializeRequestForInlineJavaScript(string(lambdaFunction));
        req.addRemoteSecrets(lambdaSecrets);
        string[1] memory setter = [_query];
        string[] memory args = new string[](setter.length);
        for (uint256 i = 0; i < setter.length; i++) {
            args[i] = setter[i];
        }
        req.addArgs(args);

        latestRequestId = sendRequest(req, subId, gasLimit);
    }

    function fulfillRequest(bytes32 requestId, bytes memory response, bytes memory err) internal override {
        latestError = err;
        res = response;
        emit OCRResponse(requestId, response, err);
    }

    function setSecret(bytes memory _secret) external onlyOwner {
        lambdaSecrets = _secret;
    }

    function setFunction(bytes memory _function) external onlyOwner {
        lambdaFunction = _function;
    }

    function setGasLimit(uint32 _gasLimit) external onlyOwner {
        gasLimit = _gasLimit;
    }

    function setSubscriptionId(uint64 _subId) external onlyOwner {
        subId = _subId;
    }

    function updateOracleAddress(address oracle) public onlyOwner {
        setOracle(oracle);
    }
}
