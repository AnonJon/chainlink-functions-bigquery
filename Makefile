-include .env

init-install:
	forge install Openzeppelin/openzeppelin-contracts foundry-rs/forge-std Openzeppelin/openzeppelin-contracts-upgradeable smartcontractkit/chainlink

install:
	forge install

# tests
tests:
	forge test -vvvvv

test-contracts-offline:
	forge test --no-match-test testFork -vvvvv

test-contracts-online:
	forge test --match-test testFork -vvvvv