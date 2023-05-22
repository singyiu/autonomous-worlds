// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import { addressToEntity } from "../Utils.sol";
import { DeFi } from "../codegen/Tables.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../defi/weth/WETH9.sol";
import "../defi/yieldfarm/IYieldFarm.sol";

contract PrivateDeFiSystem is System {
  bytes32 constant ENTITY_ID_WETH9 = keccak256(abi.encode("WETH9"));
  bytes32 constant ENTITY_ID_YEILD_FARM = keccak256(abi.encode("YEILD_FARM"));

  function _privateDeFiDepositToYieldFarm(uint256 assetAmount) public returns (uint256 shareAmount) {
    address payable weth9Address = payable(DeFi.get(ENTITY_ID_WETH9));
    WETH9 weth9 = WETH9(weth9Address);
    weth9.deposit{ value: assetAmount }();

    address yieldFarmAddress = DeFi.get(ENTITY_ID_YEILD_FARM);
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    weth9.approve(yieldFarmAddress, assetAmount);
    shareAmount = yieldFarm.deposit(address(weth9), assetAmount);
  }

  function _privateDeFiRedeemFromYieldFarm(uint256 shareAmount) public returns (uint256 assetAmount) {
    address yieldFarmAddress = DeFi.get(ENTITY_ID_YEILD_FARM);
    IYieldFarm yieldFarm = IYieldFarm(yieldFarmAddress);
    address payable weth9Address = payable(DeFi.get(ENTITY_ID_WETH9));
    WETH9 weth9 = WETH9(weth9Address);

    assetAmount = yieldFarm.redeem(weth9Address, shareAmount);
    weth9.withdraw(assetAmount);
  }
}
