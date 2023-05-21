// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { IWorld } from "../src/codegen/world/IWorld.sol";

import "../src/defi/weth/WETH9.sol";
import "../src/defi/mockyieldfarm/MockYieldFarm.sol";

contract PostDeploy is Script {
  function run(address worldAddress) external {
    // Load the private key from the `PRIVATE_KEY` environment variable (in .env)
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

    // Start broadcasting transactions from the deployer account
    vm.startBroadcast(deployerPrivateKey);

    // Deploy the WETH9 contract
    WETH9 weth9 = new WETH9();
    IWorld(worldAddress).deFiSetWETH9(address(weth9));
    console.log("WETH9 deployed to:", IWorld(worldAddress).deFiGetWETH9Address());

    // Deploy the MockYieldFarm contract
    MockYieldFarm mockYieldFarm = new MockYieldFarm();
    IWorld(worldAddress).deFiSetYieldFarm(address(mockYieldFarm));
    console.log("MockYieldFarm deployed to:", IWorld(worldAddress).deFiGetYieldFarmAddress());

    vm.stopBroadcast();
  }
}
