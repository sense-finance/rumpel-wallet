// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ISafe} from "./interfaces/external/ISafe.sol";

// For delegate calls from the safe
contract InitializationScript {
    function initialize(address module, address guard) public {
        ISafe(address(this)).enableModule(module);
        ISafe(address(this)).setGuard(guard);
    }
}
