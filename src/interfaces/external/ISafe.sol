// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

library Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface ISafe {
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        external;

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

    function isModuleEnabled(address module) external view returns (bool);
}
