// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { StakingRecord, StakingRecordData } from "../src/codegen/Tables.sol";
import { addressToEntity } from "../src/Utils.sol";

contract StakingSystemTest is MudV2Test {
  IWorld public world;

  uint256 testStakingDepositAmount01 = 1000;

  function setUp() public override {
    super.setUp();
    world = IWorld(worldAddress);
  }

  function testWorldExists() public {
    uint256 codeSize;
    address addr = worldAddress;
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testWETH9Exists() public {
    uint256 codeSize;
    address addr = world.deFiGetWETH9Address();
    assembly {
      codeSize := extcodesize(addr)
    }
    assertTrue(codeSize > 0);
  }

  function testStakingSystem() public {
    //stakingDeposit
    world.stakingDeposit{ value: testStakingDepositAmount01 }(testStakingDepositAmount01);

    StakingRecordData memory data01 = StakingRecord.get(world, address(this));
    assertEq(data01.balance, testStakingDepositAmount01);
    uint256 wETHBalance = world.deFiGetWETH9BalanceOf(address(world));
    assertEq(wETHBalance, testStakingDepositAmount01);
  }
}
