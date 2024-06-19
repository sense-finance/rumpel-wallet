// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {IGuard} from "./interfaces/external/IGuard.sol";

contract RumpelGuard is AccessControl, IGuard {
    error CallNotAllowed();

    mapping(address => mapping(bytes4 => bool)) public allowedTargets;

    // TODO: should we allow more fine-grained control on which args are allowed?
    function setCallAllowed(address target, bytes4 functionSig, bool allow) public onlyRole(DEFAULT_ADMIN_ROLE) {
        allowedTargets[target][functionSig] = allow;
    }

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
        if (!allowedTargets[to][bytes4(data)]) {
            revert CallNotAllowed();
        }
    }

    function checkAfterExecution(bytes32, bool) external view {}

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId) || interfaceId == type(IGuard).interfaceId;
    }

    fallback() external {}
}
