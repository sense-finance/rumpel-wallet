
// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe, Enum} from "../../src/interfaces/external/ISafe.sol";

contract WithdrawSafesOct28 is Script {
    address constant MODULE_OWNER = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;
    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ISafe constant SAFE_WETH = ISafe(0xBA8DceB5d0a59B80193173736180ec45fF7DBfc3);
    uint256 constant SAFE_WETH_BALANCE = 105_00000_00000_00000;

    function run() external {
        vm.startBroadcast(MODULE_OWNER);
        MODULE.exec(plan());
        vm.stopBroadcast();
    }

    function plan() public view returns (RumpelModule.Call[] memory calls) {
        address wethOwner = _soleOwner(SAFE_WETH);

        require(SAFE_WETH.isModuleEnabled(address(MODULE)));
        require(WETH.balanceOf(address(SAFE_WETH)) == SAFE_WETH_BALANCE, "weth");

        calls = new RumpelModule.Call[](1);
        calls[0] = RumpelModule.Call({
            safe: SAFE_WETH,
            to: address(WETH),
            data: abi.encodeCall(ERC20.transfer, (wethOwner, SAFE_WETH_BALANCE)),
            operation: Enum.Operation.Call
        });
    }

    function _soleOwner(ISafe safe) internal view returns (address owner) {
        address[] memory owners = safe.getOwners();
        require(owners.length == 1, "owners");
        return owners[0];
    }
}
