// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { System } from "@latticexyz/world/src/System.sol";
import { DeFi } from "../codegen/Tables.sol";

import { addressToEntity } from "../Utils.sol";
import { getKeysWithValue } from "@latticexyz/world/src/modules/keyswithvalue/getKeysWithValue.sol";
import "../defi/weth/WETH9.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeFiSystem is System {
  bytes32 constant ENTITY_ID_WETH9 = keccak256(abi.encode("WETH9"));
  bytes32 constant ENTITY_ID_YEILD_FARM = keccak256(abi.encode("YEILD_FARM"));

  function deFiSetWETH9(address contractAddress) public {
    require(contractAddress != address(0), "zero address");
    DeFi.set(ENTITY_ID_WETH9, contractAddress);
  }

  function deFiGetWETH9Address() public view returns (address payable) {
    return payable(DeFi.get(ENTITY_ID_WETH9));
  }

  function deFiGetWETH9BalanceOf(address account) public view returns (uint256) {
    require(account != address(0), "zero address");
    address payable weth9Address = deFiGetWETH9Address();
    require(weth9Address != address(0), "zero address");
    return WETH9(weth9Address).balanceOf(account);
  }

  function deFiSetYieldFarm(address contractAddress) public {
    require(contractAddress != address(0), "zero address");
    DeFi.set(ENTITY_ID_YEILD_FARM, contractAddress);
  }

  function deFiGetYieldFarmAddress() public view returns (address) {
    return DeFi.get(ENTITY_ID_YEILD_FARM);
  }

  function deFiGetYieldFarmShareBalance() public view returns (uint256) {
    address yieldFarmAddress = deFiGetYieldFarmAddress();
    require(yieldFarmAddress != address(0), "zero address");
    return IERC20(yieldFarmAddress).balanceOf(address(this));
  }
}
