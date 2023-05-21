pragma solidity ^0.8.13;

interface IYieldFarm {
  function deposit(address asset, uint256 assetAmount) external returns (uint256 shareAmount);

  function redeem(address asset, uint256 shareAmount) external returns (uint256 assetAmount);
}
