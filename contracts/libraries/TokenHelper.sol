// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../types/Errors.sol";

library TokenHelper {
    function safeTransferETH(address to, uint256 amount) internal {
        if (to == address(0)) revert Errors.InvalidRecipient();
        if (amount == 0) revert Errors.InvalidAmount();
        
        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert Errors.TransferFailed();
    }

    function safeTransfer(address token, address to, uint256 amount) internal {
        if (token == address(0)) revert Errors.InvalidToken();
        if (to == address(0)) revert Errors.InvalidRecipient();
        if (amount == 0) revert Errors.InvalidAmount();

        bool success = IERC20(token).transfer(to, amount);
        if (!success) revert Errors.TokenTransferFailed();
    }

    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        if (token == address(0)) revert Errors.InvalidToken();
        if (to == address(0)) revert Errors.InvalidRecipient();
        if (amount == 0) revert Errors.InvalidAmount();

        bool success = IERC20(token).transferFrom(from, to, amount);
        if (!success) revert Errors.TokenTransferFailed();
    }
}
