// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { StakingRecord, StakingRecordData, DeFi } from "../codegen/Tables.sol";
import { addressToEntity } from "../Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../codegen/world/IWorld.sol";
import "../defi/weth/WETH9.sol";
import "../defi/yieldfarm/IYieldFarm.sol";

contract StakingSystem is System {
  function stakingDeposit() public payable {
    uint256 assetAmount = msg.value;
    require(assetAmount > 0, "zero amount");

    //deposit to yield farm
    uint256 shareAmount = IWorld(_world())._privateDeFiDepositToYieldFarm(assetAmount);

    //update staking record
    bytes32 stakingRecordKey = addressToEntity(_msgSender());
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);
    StakingRecord.set(
      stakingRecordKey,
      stakingRecord.assetAmountProcessed + assetAmount,
      stakingRecord.shareBalance + shareAmount,
      stakingRecord.shareUnlocked
    );
  }

  function stakingRedeem(uint256 shareAmount) public returns (uint256 assetAmount) {
    require(shareAmount > 0, "zero amount");
    bytes32 stakingRecordKey = addressToEntity(_msgSender());
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);
    require(stakingRecord.shareUnlocked >= shareAmount, "insufficient unlocked share");
    require(stakingRecord.shareBalance >= shareAmount, "insufficient balance");

    //update staking record
    StakingRecord.setShareUnlocked(stakingRecordKey, stakingRecord.shareUnlocked - shareAmount);
    StakingRecord.setShareBalance(stakingRecordKey, stakingRecord.shareBalance - shareAmount);

    //redeem from yield farm
    assetAmount = IWorld(_world())._privateDeFiRedeemFromYieldFarm(shareAmount);

    //transfer ETH to _msgSender()
    payable(_msgSender()).transfer(shareAmount);
  }

  function stakingRedeemAll() public returns (uint256 assetAmount) {
    bytes32 stakingRecordKey = addressToEntity(_msgSender());
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);

    uint256 shareAmount = stakingRecord.shareUnlocked;
    require(shareAmount > 0, "zero amount");
    require(stakingRecord.shareBalance >= shareAmount, "insufficient balance");

    //update staking record
    StakingRecord.setShareUnlocked(stakingRecordKey, stakingRecord.shareUnlocked - shareAmount);
    StakingRecord.setShareBalance(stakingRecordKey, stakingRecord.shareBalance - shareAmount);

    //redeem from yield farm
    assetAmount = IWorld(_world())._privateDeFiRedeemFromYieldFarm(shareAmount);

    //transfer ETH to _msgSender()
    payable(_msgSender()).transfer(shareAmount);
  }

  function stakingHasUnlockableShare(address account) public view returns (bool) {
    require(account != address(0), "zero address");
    bytes32 stakingRecordKey = addressToEntity(account);
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);
    return stakingRecord.shareBalance > stakingRecord.shareUnlocked;
  }

  function stakingHasAssetAmountProcessed(address account) public view returns (bool) {
    require(account != address(0), "zero address");
    bytes32 stakingRecordKey = addressToEntity(account);
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);
    return stakingRecord.assetAmountProcessed > 0;
  }
}
