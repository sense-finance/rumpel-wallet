// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {IGuard} from "./interfaces/external/IGuard.sol";

// Need to be compatiable with 1.3.0 safe, so we can't use the latest module execution hooks
contract RumpelGuard is Ownable, IGuard {
    error CallNotAllowed(address target, bytes4 functionSelector);
    error PermanentlyOn();

    event SetCallAllowed(address indexed target, bytes4 indexed functionSelector, AllowListState allowListState);

    enum AllowListState {
        OFF,
        ON,
        PERMANENTLY_ON
    }

    mapping(address => mapping(bytes4 => AllowListState)) public allowedCalls; // target => functionSelector => allowListState

    constructor() Ownable(msg.sender) {}

    /**
     * @dev Add an <address>.<selector> to allow it to be called from the safe.
     * @dev Any arguments are allowed for the enabled functions.
     */
    function setCallAllowed(address target, bytes4 functionSelector, AllowListState allowListState)
        external
        onlyOwner
    {
        if (allowedCalls[target][functionSelector] == AllowListState.PERMANENTLY_ON) {
            revert PermanentlyOn();
        }

        allowedCalls[target][functionSelector] = allowListState;
        emit SetCallAllowed(target, functionSelector, allowListState);
    }

    /**
     * @notice Called by the Safe contract before a transaction is executed.
     * @dev Safe user execution hook that blocks all calls by default, including delegatecalls, unless explicitly added to the allowlist.
     */
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
        bytes4 functionSelector = bytes4(data);

        if (allowedCalls[to][functionSelector] == AllowListState.OFF) {
            revert CallNotAllowed(to, functionSelector);
        }
    }

    /**
     * @notice Called by the Safe contract after a transaction is executed.
     * @dev No-op.
     */
    function checkAfterExecution(bytes32, bool) external view {}

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IGuard).interfaceId;
    }
}
