// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ITokenUtils {
    function getBalance(address _token, address _account) external view returns (uint256 balance);
    function transfer(address _token, address _to, uint256 _amount) external payable;
    function approve(address _token, address _spender, uint256 _amount) external;
    function withdraw() external;
    function withdrawTokens(address _token, uint256 _amount) external;
}
