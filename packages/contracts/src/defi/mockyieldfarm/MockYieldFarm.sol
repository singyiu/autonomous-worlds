// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

///@dev alternatively, ERC4626 can be used. Using ERC20 here for simplicity
contract MockYieldFarm is ERC20 {
  using SafeERC20 for IERC20;

  constructor() ERC20("MockYieldFarm", "MYF") {}

  ///TODO: update mock to only accept specific assets

  function deposit(address asset, uint256 assetAmount) external returns (uint256 shareAmount) {
    require(asset != address(0), "zero address");
    require(assetAmount > 0, "zero assetAmount");

    // Transfer assets to this vault first, assuming it was approved by the sender
    IERC20(asset).safeTransferFrom(_msgSender(), address(this), assetAmount);

    //mock 1:1 asset to share price
    shareAmount = assetAmount;
    _mint(_msgSender(), shareAmount);
    return shareAmount;
  }

  function redeem(address asset, uint256 shareAmount) external returns (uint256 assetAmount) {
    require(asset != address(0), "zero address");
    require(shareAmount > 0, "zero amount");
    require(balanceOf(_msgSender()) >= shareAmount, "insufficient balance");

    //mock 1:1 asset to share price
    _burn(_msgSender(), shareAmount);

    // Transfer assets to msgSender
    assetAmount = shareAmount;
    IERC20(asset).safeTransfer(_msgSender(), assetAmount);
    return assetAmount;
  }
}
