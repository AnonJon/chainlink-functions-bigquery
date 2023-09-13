-include .env

init-install:
	forge install Openzeppelin/openzeppelin-contracts foundry-rs/forge-std Openzeppelin/openzeppelin-contracts-upgradeable smartcontractkit/chainlink

install:
	forge install && yarn && cd chainlink-functions && npm install

# tests
tests:
	forge test -vvvvv

test-contracts-offline:
	forge test --no-match-test testFork -vvvvv

test-contracts-online:
	forge test --match-test testFork -vvvvv

# Offchain Secrets Scripts

build-offchain-secrets:
	cd chainlink-functions && npx hardhat functions-build-offchain-secrets --network polygonMumbai

create-gist:
	cd chainlink-functions && gh gist create offchain-secrets.json

encrypt-gist:
	node utils/encrypt.js


# Contract Scripts

deploy-BQ-weather:
	forge script script/Deploy.BQWeather.s.sol:DeployScript --rpc-url ${RPC_URL} --etherscan-api-key ${EXPLORER_KEY} --broadcast --verify -vvvv --ffi

set-functions-consumer:
	forge script script/Set.FunctionsConsumer.s.sol:SetFunctionsConsumerScript --rpc-url ${RPC_URL} --broadcast -vvvv --ffi

set-lambda:
	forge script script/Set.Lambda.s.sol:SetLambdaScript --rpc-url ${RPC_URL} --broadcast -vvvv --ffi