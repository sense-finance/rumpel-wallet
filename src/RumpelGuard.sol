// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {IGuard} from "./interfaces/external/IGuard.sol";

contract RumpelGuard is AccessControl, IGuard {
    error CallNotAllowed();

    event SetCallAllowed(address indexed target, bytes4 indexed functionSig, bool allow);
    event SetCallPermenantlyAllowed(address indexed target, bytes4 indexed functionSig);

    mapping(address => mapping(bytes4 => bool)) public allowedCalls;
    mapping(address => mapping(bytes4 => bool)) public permanentlyAllowedCalls;

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setCallAllowed(address target, bytes4 functionSig, bool allow) public onlyRole(DEFAULT_ADMIN_ROLE) {
        allowedCalls[target][functionSig] = allow;
        emit SetCallAllowed(target, functionSig, allow);
    }

    function setCallPermenantlyAllowed(address target, bytes4 functionSig) public onlyRole(DEFAULT_ADMIN_ROLE) {
        permanentlyAllowedCalls[target][functionSig] = true; // One way, only true
        emit SetCallPermenantlyAllowed(target, functionSig);
    }

    // This guard blocks all calls by default, including delegatecalls, unless explicitly whitelisted
    function checkTransaction(
        address to,
        uint256,
        bytes memory data,
        Enum.Operation,
        uint256,
        uint256,
        uint256,
        address,
        address payable,
        bytes memory,
        address
    ) external view {
        bytes4 functionSig = bytes4(data);
        // TODO: check value?

        if (!allowedCalls[to][functionSig] && !permanentlyAllowedCalls[to][functionSig]) {
            revert CallNotAllowed();
        }
    }

    function checkAfterExecution(bytes32, bool) external view {}

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId) || interfaceId == type(IGuard).interfaceId;
    }
}
