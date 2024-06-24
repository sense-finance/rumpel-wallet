// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ISafe} from "./interfaces/external/ISafe.sol";

// For delegatecalls for safe initialization
contract InitializationScript {
    function initialize(address module, address guard) public {
        ISafe(address(this)).enableModule(module);
        ISafe(address(this)).setGuard(guard);
    }
}
