// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface ISafe {
    function getTransactionHash(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        uint256 _nonce
    ) external view returns (bytes32);

    function execTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures
    ) external payable returns (bool success);

    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        external
        returns (bool success);

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;

    function enableModule(address module) external;

    function setGuard(address guard) external;

    function getGuard() external view returns (address);

    function getOwners() external view returns (address[] memory);

    function getThreshold() external view returns (uint256);

    function isModuleEnabled(address module) external view returns (bool);
}
