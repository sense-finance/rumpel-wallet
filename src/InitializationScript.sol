// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ISafe} from "./interfaces/external/ISafe.sol";

// Delegatecall script to initialize safes
contract InitializationScript {
    // This function is called via delegatecall by newly created safes
    function initialize(address module, address guard) external {
        ISafe(address(this)).enableModule(module);
        ISafe(address(this)).setGuard(guard);
    }
}
