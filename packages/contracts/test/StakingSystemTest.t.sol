// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { StakingRecord, StakingRecordData } from "../src/codegen/Tables.sol";
import { addressToEntity } from "../src/Utils.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract StakingSystemTest is MudV2Test {
  IWorld public world;
  uint256 testStakingDepositAmount01 = 1000;

  fallback() external payable {
    console.log("fallback", msg.value);
  }

  receive() external payable {
    console.log("receive", msg.value);
  }

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

  function testStakingSystem() public {
    bytes32 stakingRecordKey = addressToEntity(address(this));
    address yieldFarmAddress = world.deFiGetContractAddressFromKey(keccak256(abi.encode("YEILD_FARM")));

    //stakingDeposit
    world.stakingDeposit{ value: testStakingDepositAmount01 }();
    StakingRecordData memory stakingRecord01 = StakingRecord.get(world, stakingRecordKey);
    assertEq(stakingRecord01.shareBalance, testStakingDepositAmount01);
    assertEq(stakingRecord01.shareAmountLocked, 0);
    assertEq(IERC20(yieldFarmAddress).balanceOf(address(world)), testStakingDepositAmount01);

    //stakingRedeem
    //world.stakingRedeem(testStakingDepositAmount01);
    //StakingRecordData memory stakingRecord02 = StakingRecord.get(world, stakingRecordKey);
    //assertEq(stakingRecord02.shareBalance, 0);
    //assertEq(IERC20(yieldFarmAddress).balanceOf(address(world)), 0);
  }
}
