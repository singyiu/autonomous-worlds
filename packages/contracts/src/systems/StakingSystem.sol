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
      stakingRecord.shareAmountLocked
    );
  }

  function stakingRedeem(uint256 shareAmount) public {
    require(shareAmount > 0, "zero amount");
    bytes32 stakingRecordKey = addressToEntity(_msgSender());
    StakingRecordData memory stakingRecord = StakingRecord.get(stakingRecordKey);
    require((stakingRecord.shareBalance - stakingRecord.shareAmountLocked) >= shareAmount, "insufficient balance");

    //update staking record
    StakingRecord.setShareBalance(stakingRecordKey, stakingRecord.shareBalance - shareAmount);

    //redeem from yield farm
    uint256 assetAmount = IWorld(_world())._privateDeFiRedeemFromYieldFarm(shareAmount);

    //transfer ETH to _msgSender()
    payable(_msgSender()).transfer(shareAmount);
  }
}
