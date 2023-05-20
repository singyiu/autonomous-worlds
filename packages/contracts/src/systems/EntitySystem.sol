// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { EntityInfo, EntityOwnership } from "../codegen/Tables.sol";

import { addressToEntity } from "../Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

contract EntitySystem is System {
  function entityInfoRegister(bytes32 entityId, string calldata name, string calldata metadata) public {
    require(entityId != 0, "invalid entityId");
    require(EntityInfo.get(entityId).creator == address(0), "entity already exist");
    EntityInfo.set(entityId, _msgSender(), name, metadata);
  }

  function entityOwnershipMint(bytes32 entityId, uint256 amount) public {
    require(entityId != 0, "invalid entityId");
    require(amount > 0, "zero amount");
    require(EntityInfo.get(entityId).creator != address(0), "entityInfo not exist");
    //TODO: mint requirement ?
    uint256 currentBalance = EntityOwnership.get(entityId, _msgSender());
    EntityOwnership.set(entityId, _msgSender(), currentBalance + amount);
  }

  function entityOwnershipTransferTo(bytes32 entityId, address toOwner, uint256 amount) public payable {
    require(entityId != 0, "invalid entityId");
    require(toOwner != address(0) && toOwner != _msgSender(), "invalid toOwner");
    require(amount > 0, "zero amount");
    uint256 currentBalance = EntityOwnership.get(entityId, _msgSender());
    require(currentBalance >= amount, "insufficient balance");
    uint256 currentBalanceOfToOwner = EntityOwnership.get(entityId, toOwner);
    EntityOwnership.set(entityId, _msgSender(), currentBalance - amount);
    EntityOwnership.set(entityId, toOwner, currentBalanceOfToOwner + amount);
  }
}
