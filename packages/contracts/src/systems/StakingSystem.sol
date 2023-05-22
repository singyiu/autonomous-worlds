// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { StakingRecord, StakingRecordData, DeFi } from "../codegen/Tables.sol";

import { addressToEntity } from "../Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import "../defi/weth/WETH9.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../defi/yieldfarm/IYieldFarm.sol";

contract StakingSystem is System {
  function stakingDeposit() public payable {
    uint256 assetAmount = msg.value;
    require(assetAmount > 0, "zero amount");

    //wrap ETH to wETH
    address payable weth9Address = payable(DeFi.get(keccak256(abi.encode("WETH9"))));
    WETH9 weth9 = WETH9(weth9Address);
    weth9.deposit{ value: assetAmount }();

    //deposit to yield farm
    address yieldFarmAddress = DeFi.get(keccak256(abi.encode("YEILD_FARM")));
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    weth9.approve(yieldFarmAddress, assetAmount);
    uint256 shareAmount = yieldFarm.deposit(address(weth9), assetAmount);

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
    StakingRecord.setShareBalance(stakingRecordKey, stakingRecord.shareBalance - shareAmount);

    //withdraw from yield farm

    //wrap wETH to ETH

    //transfer ETH to _msgSender()
    payable(_msgSender()).transfer(shareAmount);
  }
}
