// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {IGuard} from "./interfaces/external/IGuard.sol";

contract RumpelGuard is Ownable, IGuard {
    constructor() Ownable(msg.sender) {}

    function setUp() public {}

    mapping(address => mapping(bytes4 => bool)) public allowedTargets;

    function setCallAllowed(address target, bytes4 functionSig, bool allow) public onlyOwner {
        allowedTargets[target][functionSig] = allow;
    }

    function isAllowedCall(address target, bytes4 functionSig) public view returns (bool) {
        return (allowedTargets[target][functionSig]);
    }

    fallback() external {
        // Don't revert on fallback to avoid issues in case of a Safe upgrade
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
        require(allowedTargets[to][bytes4(data)], "Call is not allowed");
    }

    function checkAfterExecution(bytes32, bool) external view {}

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IGuard).interfaceId;
    }
}
