// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {Enum} from "./interfaces/external/ISafe.sol";
import {ISafe} from "./interfaces/external/ISafe.sol";

contract RumpelModule is AccessControl {
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
        returns (bool)
    {
        return safe.execTransactionFromModule(to, value, data, operation);
    }

    function sweep(ISafe[] memory safes, ERC20 token) public virtual onlyRole(SWEEPER_ROLE) {
        for (uint256 i = 0; i < safes.length; i++) {
            safes[i].execTransactionFromModule(
                address(token),
                0,
                abi.encodeCall(ERC20.transfer, (rumpelVault, token.balanceOf(address(safes[i])))),
                Enum.Operation.Call
            );
        }
    }

    function setRumpelVault(address _rumpelVault) public virtual onlyRole(DEFAULT_ADMIN_ROLE) {
        rumpelVault = _rumpelVault;
    }
}
