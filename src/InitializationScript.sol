// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ISafe} from "./interfaces/external/ISafe.sol";
import {Enum} from "./interfaces/external/ISafe.sol";
import {RumpelGuard} from "./RumpelGuard.sol";

/// @notice Delegatecall script to initialize Safes.
contract InitializationScript {
    error InitializationFailed();

    event InitialCall(address to, bytes data);

    /// @notice This function is called via delegatecall by newly created Safes.
    function initialize(address module, address guard, address to, bytes memory data) external {
        ISafe safe = ISafe(address(this));
        safe.enableModule(module);
        safe.setGuard(guard);

        // First call
        if (to != address(0)) {
            // TODO: single, should this be multi
            RumpelGuard(guard).checkTransaction(
                to, 0, data, Enum.Operation.Call, 0, 0, 0, address(0), payable(address(0)), bytes(""), address(0)
            );

            bool success;
            assembly {
                success := call(sub(gas(), 500), to, 0, add(data, 0x20), mload(data), 0, 0)
            }

            if (!success) revert InitializationFailed();

            emit InitialCall(to, data);
        }
    }
}
