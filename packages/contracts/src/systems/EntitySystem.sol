// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { EntityInfo, EntityOwnership, EntityMarketplaceSell } from "../codegen/Tables.sol";

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

  function _entityOwnershipTransfer(bytes32 entityId, address fromOwner, address toOwner, uint256 amount) internal {
    require(entityId != 0, "invalid entityId");
    require(fromOwner != address(0), "invalid fromOwner");
    require(toOwner != address(0), "invalid toOwner");
    require(amount > 0, "zero amount");
    uint256 currentBalanceOfFromOwner = EntityOwnership.get(entityId, fromOwner);
    require(currentBalanceOfFromOwner >= amount, "insufficient balance");
    uint256 currentBalanceOfToOwner = EntityOwnership.get(entityId, toOwner);
    //TODO: update entityMarketplaceSell if needed
    EntityOwnership.set(entityId, fromOwner, currentBalanceOfFromOwner - amount);
    EntityOwnership.set(entityId, toOwner, currentBalanceOfToOwner + amount);
  }

  //_msgSender is the fromOwner
  function entityOwnershipTransferTo(bytes32 entityId, address toOwner, uint256 amount) public {
    require(toOwner != _msgSender(), "invalid toOwner");
    _entityOwnershipTransfer(entityId, _msgSender(), toOwner, amount);
  }

  //_msgSender is the entityOwner and seller
  function entityMarketplaceSellRegister(bytes32 entityId, uint256 unitPrice, uint256 amount) public {
    require(entityId != 0, "invalid entityId");
    require(unitPrice > 0, "zero unitPrice");
    require(amount > 0, "zero amount");
    uint256 currentBalance = EntityOwnership.get(entityId, _msgSender());
    require(currentBalance >= amount, "insufficient balance");
    EntityMarketplaceSell.set(entityId, _msgSender(), unitPrice, amount);
  }

  //_msgSender is the buyer
  function entityMarketplaceBuyFrom(bytes32 entityId, address seller, uint256 amount) public payable {
    require(entityId != 0, "invalid entityId");
    uint256 amountForSale = EntityMarketplaceSell.get(entityId, seller).amount;
    require(amountForSale >= amount, "insufficient amountForSale");
    uint256 unitPrice = EntityMarketplaceSell.get(entityId, seller).unitPrice;
    uint256 totalPrice = unitPrice * amount;
    require(msg.value >= totalPrice, "insufficient payment");

    payable(seller).transfer(totalPrice);

    if (amountForSale == amount) {
      EntityMarketplaceSell.deleteRecord(entityId, seller);
    } else {
      EntityMarketplaceSell.set(entityId, seller, unitPrice, amountForSale - amount);
    }

    _entityOwnershipTransfer(entityId, seller, _msgSender(), amount);
  }
}
