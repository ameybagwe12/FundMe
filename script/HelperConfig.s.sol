// SPDX-License-Identifier: SEE LICENSE IN LICENSE
// Deplot mocks when we are on a local anvil chain
// Keep track of contract addr across diff chains
// Sepolia ETH/USD
// MAINNET ETH/USD

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MocksV3Aggregator.sol";

contract HelperConfig is Script {
    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab existing addr from live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    constructor () {
        if(block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed addr
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // price feed addr
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // price feed addr
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5C00128d4d1c2F4f652C267d7bcdD7aC99C16E16
        });
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if(activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. Deploy mock contracts
        // 2. Returning mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig; 
    }
}