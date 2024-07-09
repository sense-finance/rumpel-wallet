// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";

contract RumpelModule is Ownable {
    error ExecFailed(address safe, address target, bytes data);
    error CallBlocked(address target, bytes4 functionSelector);

    event ExecutionFromModule(address indexed safe, address indexed target, uint256 value, bytes data);
    event SetModuleCallBlocked(address indexed target, bytes4 indexed functionSelector);

    mapping(address => mapping(bytes4 => bool)) public blockedModuleCalls; // target => functionSelector => blocked

    struct Call {
        ISafe safe;
        address to;
        uint256 value;
        bytes data;
    }

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Executes a series of calls on behalf of Safe contracts.
     * @param calls An array of Call structs containing the details of each call to be executed.
     */
    function exec(Call[] calldata calls) external onlyOwner {
        for (uint256 i = 0; i < calls.length;) {
            Call calldata call = calls[i];
            bool blockedCall = blockedModuleCalls[call.to][bytes4(call.data)];
            bool callingSafe = address(call.safe) == call.to;

            // If this transaction is to a safe itself, to e.g. update config, we check the zero address for blocked calls.
            if (blockedCall || (callingSafe && blockedModuleCalls[address(0)][bytes4(call.data)])) {
                revert CallBlocked(call.to, bytes4(call.data));
            }

            bool success = call.safe.execTransactionFromModule(call.to, call.value, call.data, Enum.Operation.Call); // No delegatecalls

            if (!success) {
                revert ExecFailed(address(call.safe), call.to, call.data);
            }

            emit ExecutionFromModule(address(call.safe), call.to, call.value, call.data);

            unchecked {
                ++i;
            }
        }
    }

    /**
     * @dev Add <address>.<functionSelector> to prevent it from being executed via the module.
     * Useful as an assurance that the RumpelModule will never e.g. transfer a user's USDC.
     * Zero address is used for the target to block calls to a safe itself.
     */
    function addModuleCallBlocked(address target, bytes4 functionSelector) external onlyOwner {
        blockedModuleCalls[target][functionSelector] = true;
        emit SetModuleCallBlocked(target, functionSelector);
    }
}
