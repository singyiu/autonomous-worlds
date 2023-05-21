// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { StakingRecord, StakingRecordData } from "../codegen/Tables.sol";

import { addressToEntity } from "../Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

contract StakingSystem is System {
  function stakingDeposit(uint256 amount) public payable {
    require(amount > 0, "zero amount");
    require(msg.value == amount, "invalid deposit amount");
    StakingRecordData memory stakingRecord = StakingRecord.get(_msgSender());
    StakingRecord.set(
      _msgSender(),
      stakingRecord.totalProcessed + amount,
      stakingRecord.balance + amount,
      stakingRecord.lockedAmount
    );
  }

  function stakingRedeem(uint256 amount) public {
    require(amount > 0, "zero amount");
    StakingRecordData memory stakingRecord = StakingRecord.get(_msgSender());
    require((stakingRecord.balance - stakingRecord.lockedAmount) >= amount, "insufficient balance");
    StakingRecord.set(
      _msgSender(),
      stakingRecord.totalProcessed,
      stakingRecord.balance - amount,
      stakingRecord.lockedAmount
    );
    payable(_msgSender()).transfer(amount);
  }
}
