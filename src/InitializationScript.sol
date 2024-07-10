// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ISafe} from "./interfaces/external/ISafe.sol";

/// @notice Delegatecall script to initialize Safes.
contract InitializationScript {
    /// @notice This function is called via delegatecall by newly created Safes.
    function initialize(address module, address guard) external {
        ISafe(address(this)).enableModule(module);
        ISafe(address(this)).setGuard(guard);
    }
}
