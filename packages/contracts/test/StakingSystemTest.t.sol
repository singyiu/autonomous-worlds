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
    //stakingDeposit
    world.stakingDeposit{ value: testStakingDepositAmount01 }();

    bytes32 stakingRecordKey = addressToEntity(address(this));
    StakingRecordData memory data01 = StakingRecord.get(world, stakingRecordKey);
    assertEq(data01.shareBalance, testStakingDepositAmount01);

    address yieldFarmAddress = world.deFiGetContractAddressFromKey(keccak256(abi.encode("YEILD_FARM")));
    assertEq(IERC20(yieldFarmAddress).balanceOf(address(world)), testStakingDepositAmount01);
  }
}
