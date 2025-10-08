// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Script} from "forge-std/Script.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe, Enum} from "../../src/interfaces/external/ISafe.sol";

contract WithdrawSafes is Script {
    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ISafe constant SAFE_WETH = ISafe(0x358b600115dB863F57591152010fb112F1EA6616);
    ISafe constant SAFE_ETHFI = ISafe(0xbBa9d6349d63E667d42Ef1F3c4D180917BF6124A);
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 constant ETHFI = ERC20(0xFe0c30065B384F05761f15d0CC899D4F9F9Cc0eB);

    uint256 constant SAFE_WETH_BALANCE = 3_591_000_000_000_000;
    uint256 constant SAFE_ETHFI_BALANCE = 41_997_758_522_023_740_603;

    function run() external {
        vm.startBroadcast(vm.envUint("MODULE_OWNER_PK"));
        MODULE.exec(plan());
        vm.stopBroadcast();
    }

    function plan() public view returns (RumpelModule.Call[] memory calls) {
        address wethOwner = _soleOwner(SAFE_WETH);
        address ethfiOwner = _soleOwner(SAFE_ETHFI);

        require(SAFE_WETH.isModuleEnabled(address(MODULE)) && SAFE_ETHFI.isModuleEnabled(address(MODULE)), "module");
        require(WETH.balanceOf(address(SAFE_WETH)) == SAFE_WETH_BALANCE, "weth");
        require(ETHFI.balanceOf(address(SAFE_ETHFI)) == SAFE_ETHFI_BALANCE, "ethfi");

        calls = new RumpelModule.Call[](2);
        calls[0] = RumpelModule.Call({
            safe: SAFE_WETH,
            to: address(WETH),
            data: abi.encodeCall(ERC20.transfer, (wethOwner, SAFE_WETH_BALANCE)),
            operation: Enum.Operation.Call
        });
        calls[1] = RumpelModule.Call({
            safe: SAFE_ETHFI,
            to: address(ETHFI),
            data: abi.encodeCall(ERC20.transfer, (ethfiOwner, SAFE_ETHFI_BALANCE)),
            operation: Enum.Operation.Call
        });
    }

    function _soleOwner(ISafe safe) internal view returns (address owner) {
        address[] memory owners = safe.getOwners();
        require(owners.length == 1, "owners");
        return owners[0];
    }
}
