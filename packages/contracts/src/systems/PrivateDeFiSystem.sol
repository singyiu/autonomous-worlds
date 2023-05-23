// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { addressToEntity } from "../Utils.sol";
import { DeFi, StakingRecord, StakingRecordData, DeFiSingleton } from "../codegen/Tables.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../defi/weth/WETH9.sol";
import "../defi/yieldfarm/IYieldFarm.sol";

contract PrivateDeFiSystem is System {
  bytes32 constant ENTITY_ID_WETH9 = keccak256(abi.encode("WETH9"));
  bytes32 constant ENTITY_ID_YEILD_FARM = keccak256(abi.encode("YEILD_FARM"));

  function _privateDeFiDepositToYieldFarm(uint256 assetAmount) public returns (uint256 shareAmount) {
    require(assetAmount > 0, "zero amount");
    DeFiSingleton.setTotalAssetAmount(DeFiSingleton.getTotalAssetAmount() + assetAmount);
    address payable weth9Address = payable(DeFi.get(ENTITY_ID_WETH9));
    WETH9 weth9 = WETH9(weth9Address);
    weth9.deposit{ value: assetAmount }();

    address yieldFarmAddress = DeFi.get(ENTITY_ID_YEILD_FARM);
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    weth9.approve(yieldFarmAddress, assetAmount);
    shareAmount = yieldFarm.deposit(address(weth9), assetAmount);
    DeFiSingleton.setTotalShareAmount(DeFiSingleton.getTotalShareAmount() + shareAmount);
  }

  function _privateDeFiIncreaseStakingShareUnlockedUpTo(address account, uint256 shareAmount) public {
    require(account != address(0), "zero address");
    require(shareAmount > 0, "zero amount");
    bytes32 stakingRecordKey = addressToEntity(account);
    StakingRecordData memory stakingRecordData = StakingRecord.get(stakingRecordKey);

    uint256 unlockableShareAmount = stakingRecordData.shareBalance - stakingRecordData.shareUnlocked;
    if (unlockableShareAmount >= shareAmount) {
      StakingRecord.setShareUnlocked(stakingRecordKey, stakingRecordData.shareUnlocked + shareAmount);
    } else {
      StakingRecord.setShareUnlocked(stakingRecordKey, stakingRecordData.shareUnlocked + unlockableShareAmount);
    }
  }

  function _privateDeFiRedeemFromYieldFarm(uint256 shareAmount) public returns (uint256 assetAmount) {
    require(shareAmount > 0, "zero amount");
    DeFiSingleton.setTotalShareAmount(DeFiSingleton.getTotalShareAmount() - shareAmount);
    address yieldFarmAddress = DeFi.get(ENTITY_ID_YEILD_FARM);
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    address payable weth9Address = payable(DeFi.get(ENTITY_ID_WETH9));
    WETH9 weth9 = WETH9(weth9Address);

    assetAmount = yieldFarm.redeem(weth9Address, shareAmount);
    DeFiSingleton.setTotalAssetAmount(DeFiSingleton.getTotalAssetAmount() - assetAmount);
    weth9.withdraw(assetAmount);
  }
}
