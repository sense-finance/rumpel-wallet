// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";

contract RumpelModule is AccessControl {
    error CallBlocked(address target, bytes4 data);
    error ExecFailed(address safe, address target, bytes data);

    event ExecutionFromModule(address indexed safe, address indexed target, uint256 value, bytes data);
    event TokensSwepped(address indexed safe, address indexed token, uint256 amount);
    event RumpelVaultUpdated(address indexed newVault);
    event BlockedCallAdded(address indexed target, bytes4 indexed data);

    mapping(address => mapping(bytes4 => bool)) public blockedCalls;
    bytes32 public constant SWEEPER_ROLE = keccak256("SWEEPER_ROLE");
    address public rumpelVault;

    constructor(address _rumpelVault) {
        rumpelVault = _rumpelVault;
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    struct Call {
        ISafe safe;
        address to;
        uint256 value;
        bytes data;
    }

    struct Sweep {
        ISafe safe;
        ERC20 token;
        uint256 amount;
    }

    /**
     * @dev Executes a series of calls on behalf of Safe contracts.
     * @param calls An array of Call structs containing the details of each call to be executed.
     */
    function exec(Call[] memory calls) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i = 0; i < calls.length; i++) {
            if (blockedCalls[calls[i].to][bytes4(calls[i].data)]) {
                // Calls that the module is prevented from making
                revert CallBlocked(calls[i].to, bytes4(calls[i].data));
            }
            // TODO: what about eth trasnfers?

            // No delegatecalls
            bool success =
                calls[i].safe.execTransactionFromModule(calls[i].to, calls[i].value, calls[i].data, Enum.Operation.Call);

            if (!success) {
                revert ExecFailed(address(calls[i].safe), calls[i].to, calls[i].data);
            }

            emit ExecutionFromModule(address(calls[i].safe), calls[i].to, calls[i].value, calls[i].data);
        }
    }

    // Utils ----

    // Sweep token from multiple safes at once
    function sweep(Sweep[] memory sweeps) public virtual onlyRole(SWEEPER_ROLE) {
        for (uint256 i = 0; i < sweeps.length; i++) {
            sweeps[i].safe.execTransactionFromModule(
                address(sweeps[i].token),
                0,
                abi.encodeCall(ERC20.transfer, (rumpelVault, sweeps[i].amount)),
                Enum.Operation.Call
            );
            emit TokensSwepped(address(sweeps[i].safe), address(sweeps[i].token), sweeps[i].amount);
        }
    }

    // Admin ---

    /**
     * @dev Add address.call to prevent it from being executed via the module.
     * Useful as an assurance that the RumpelModule will never e.g. transfer a user's USDC.
     */
    function addBlockedCall(address to, bytes4 data) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        blockedCalls[to][data] = true;
        emit BlockedCallAdded(to, data);
    }

    function setRumpelVault(address _rumpelVault) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        rumpelVault = _rumpelVault;
        emit RumpelVaultUpdated(_rumpelVault);
    }
}
