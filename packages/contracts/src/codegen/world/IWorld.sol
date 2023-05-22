// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/* Autogenerated file. Do not edit manually. */

import { IBaseWorld } from "@latticexyz/world/src/interfaces/IBaseWorld.sol";

import { IDeFiSystem } from "./IDeFiSystem.sol";
import { IEntitySystem } from "./IEntitySystem.sol";
import { IPlayerSystem } from "./IPlayerSystem.sol";
import { IPrivateDeFiSystem } from "./IPrivateDeFiSystem.sol";
import { IStakingSystem } from "./IStakingSystem.sol";

/**
 * The IWorld interface includes all systems dynamically added to the World
 * during the deploy process.
 */
interface IWorld is IBaseWorld, IDeFiSystem, IEntitySystem, IPlayerSystem, IPrivateDeFiSystem, IStakingSystem {

}
