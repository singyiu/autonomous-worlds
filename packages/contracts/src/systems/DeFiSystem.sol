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

  function deFiGetContractAddressFromKey(bytes32 entityKey) public view returns (address contractAddress) {
    contractAddress = DeFi.get(entityKey);
    require(contractAddress != address(0), "zero address");
  }

  function deFiSetWETH9(address contractAddress) public {
    require(contractAddress != address(0), "zero address");
    DeFi.set(ENTITY_ID_WETH9, contractAddress);
  }

  function deFiSetYieldFarm(address contractAddress) public {
    require(contractAddress != address(0), "zero address");
    DeFi.set(ENTITY_ID_YEILD_FARM, contractAddress);
  }
}
