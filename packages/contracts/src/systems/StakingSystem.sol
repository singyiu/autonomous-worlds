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
  function stakingDeposit(uint256 amount) public payable {
    require(amount > 0, "zero amount");
    require(msg.value == amount, "invalid deposit amount");

    //wrap ETH to wETH
    address payable weth9Address = payable(DeFi.get(keccak256(abi.encode("WETH9"))));
    WETH9 weth9 = WETH9(weth9Address);
    weth9.deposit{ value: amount }();

    //deposit to yield farm
    address yieldFarmAddress = DeFi.get(keccak256(abi.encode("YEILD_FARM")));
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    weth9.approve(yieldFarmAddress, amount);
    uint256 shareAmount = yieldFarm.deposit(address(weth9), amount);

    //update staking record
    StakingRecordData memory stakingRecord = StakingRecord.get(_msgSender());
    StakingRecord.set(
      _msgSender(),
      stakingRecord.totalProcessed + shareAmount,
      stakingRecord.balance + shareAmount,
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
