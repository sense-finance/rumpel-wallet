// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";

contract RumpelModule is AccessControl {
    error ExecFailed();

    bytes32 public constant SWEEPER_ROLE = keccak256("SWEEPER_ROLE");
    address public rumpelVault;

    constructor(address _rumpelVault) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        rumpelVault = _rumpelVault;
    }

    function exec(ISafe safe, address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        virtual
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        bool success = safe.execTransactionFromModule(to, value, data, operation);
        if (!success) {
            revert ExecFailed();
        }
    }

    struct Sweep {
        ISafe safe;
        ERC20 token;
        uint256 amount;
    }

    function sweep(Sweep[] memory sweeps) public virtual onlyRole(SWEEPER_ROLE) {
        for (uint256 i = 0; i < sweeps.length; i++) {
            sweeps[i].safe.execTransactionFromModule(
                address(sweeps[i].token),
                0,
                abi.encodeCall(ERC20.transfer, (rumpelVault, sweeps[i].amount)),
                Enum.Operation.Call
            );
        }
    }

    function setRumpelVault(address _rumpelVault) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        rumpelVault = _rumpelVault;
    }
}
