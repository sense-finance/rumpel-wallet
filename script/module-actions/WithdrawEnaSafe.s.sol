// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe, Enum} from "../../src/interfaces/external/ISafe.sol";

contract WithdrawEnaSafe is Script {
    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ISafe constant SAFE_ENA = ISafe(0xEF1d1AE1846c7DC389fba7BFdd17644f1CD57792);
    ERC20 constant ENA = ERC20(0x57e114B691Db790C35207b2e685D4A43181e6061);

    uint256 constant SAFE_ENA_BALANCE = 115_999_375_831_457_991_983;

    function run() external {
        vm.startBroadcast(vm.envUint("MODULE_OWNER_PK"));
        MODULE.exec(plan());
        vm.stopBroadcast();
    }

    function plan() public view returns (RumpelModule.Call[] memory calls) {
        address owner = _soleOwner(SAFE_ENA);

        require(SAFE_ENA.isModuleEnabled(address(MODULE)), "module");
        require(ENA.balanceOf(address(SAFE_ENA)) == SAFE_ENA_BALANCE, "ena");

        calls = new RumpelModule.Call[](1);
        calls[0] = RumpelModule.Call({
            safe: SAFE_ENA,
            to: address(ENA),
            data: abi.encodeCall(ERC20.transfer, (owner, SAFE_ENA_BALANCE)),
            operation: Enum.Operation.Call
        });
    }

    function _soleOwner(ISafe safe) internal view returns (address owner) {
        address[] memory owners = safe.getOwners();
        require(owners.length == 1, "owners");
        return owners[0];
    }
}
