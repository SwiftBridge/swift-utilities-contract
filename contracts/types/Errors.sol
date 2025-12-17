// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Errors {
    error InvalidTarget();
    error BatchTooLarge();
    error NoOperations();
    error InvalidRecipient();
    error InvalidAmount();
    error InsufficientETH();
    error TransferFailed();
    error InvalidToken();
    error InvalidSpender();
    error NotAuthorized();
    error ContractPaused();
    error NoBalanceToWithdraw();
    error TokenTransferFailed();
    error ReentrancyGuardReentrantCall();
}
