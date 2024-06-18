// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";

contract RumpelModule is Ownable {
    constructor() Ownable(msg.sender) {}

    function exec(ISafe safe, address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        virtual
        onlyOwner
        returns (bool)
    {
        return safe.execTransactionFromModule(to, value, data, operation);
    }
}
