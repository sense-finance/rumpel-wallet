// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ISafe} from "./interfaces/external/ISafe.sol";

contract InitializationScript {
    // This function is pressumed to be delegate called by the safe
    function initialize(address module, address guard) public {
        ISafe(address(this)).enableModule(module);
        ISafe(address(this)).setGuard(guard);
    }
}
