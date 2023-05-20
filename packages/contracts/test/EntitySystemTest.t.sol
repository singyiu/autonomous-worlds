// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import { MudV2Test } from "@latticexyz/std-contracts/src/test/MudV2Test.t.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import { IWorld } from "../src/codegen/world/IWorld.sol";
import { EntityInfo, EntityInfoData, EntityOwnership, EntityMarketplaceSell } from "../src/codegen/Tables.sol";
import { addressToEntity } from "../src/Utils.sol";

contract EntitySystemTest is MudV2Test {
  IWorld public world;

  bytes32 entityId01 = keccak256(abi.encode("1"));
  uint256 testEntityOwnershipMintAmount01 = 10;
  address testEntityOwnershipTransferToAddress01 = address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8);
  uint256 testEntityOwnershipTransferToAmount01 = 2;
  uint256 entityMarketplaceSellRegisterUnitPrice01 = 1000;
  uint256 entityMarketplaceSellRegisterAmount01 = 2;
  uint256 entityMarketplaceBuyFromAmount01 = 2;

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

  function testEntitySystem() public {
    //testEntityInfoRegister
    world.entityInfoRegister(entityId01, "name", "metadata");
    EntityInfoData memory data01 = EntityInfo.get(world, entityId01);
    assertTrue(data01.creator != address(0));

    //testEntityOwnershipMint
    world.entityOwnershipMint(entityId01, testEntityOwnershipMintAmount01);
    uint256 balance01 = EntityOwnership.get(world, entityId01, address(this));
    assertEq(balance01, testEntityOwnershipMintAmount01);

    //testEntityOwnershipTransferTo
    world.entityOwnershipTransferTo(
      entityId01,
      testEntityOwnershipTransferToAddress01,
      testEntityOwnershipTransferToAmount01
    );
    assertEq(
      EntityOwnership.get(world, entityId01, address(this)),
      testEntityOwnershipMintAmount01 - testEntityOwnershipTransferToAmount01
    );
    assertEq(
      EntityOwnership.get(world, entityId01, testEntityOwnershipTransferToAddress01),
      testEntityOwnershipTransferToAmount01
    );

    //entityMarketplaceSellRegister
    world.entityMarketplaceSellRegister(
      entityId01,
      entityMarketplaceSellRegisterUnitPrice01,
      entityMarketplaceSellRegisterAmount01
    );
    assertEq(
      EntityMarketplaceSell.get(world, entityId01, address(this)).unitPrice,
      entityMarketplaceSellRegisterUnitPrice01
    );
    assertEq(EntityMarketplaceSell.get(world, entityId01, address(this)).amount, entityMarketplaceSellRegisterAmount01);
  }
}
