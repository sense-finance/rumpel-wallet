// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test} from "forge-std/Test.sol";

import {WithdrawEnaSafe} from "../../script/module-actions/WithdrawEnaSafe.s.sol";
import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe} from "../../src/interfaces/external/ISafe.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract WithdrawEnaSafeTest is Test {
    uint256 constant BLOCK_NUMBER = 23_549_942;
    address constant ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ISafe constant SAFE_ENA = ISafe(0xEF1d1AE1846c7DC389fba7BFdd17644f1CD57792);
    ERC20 constant ENA = ERC20(0x57e114B691Db790C35207b2e685D4A43181e6061);

    uint256 constant SAFE_ENA_BALANCE = 115_999_375_831_457_991_983;

    WithdrawEnaSafe script;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), BLOCK_NUMBER);
        script = new WithdrawEnaSafe();
    }

    function testPlanMovesTokensToOwner() public {
        address owner = SAFE_ENA.getOwners()[0];

        uint256 safeBalance = ENA.balanceOf(address(SAFE_ENA));
        uint256 ownerBefore = ENA.balanceOf(owner);

        assertEq(safeBalance, SAFE_ENA_BALANCE);

        RumpelModule.Call[] memory calls = script.plan();

        vm.prank(ADMIN);
        MODULE.exec(calls);

        assertEq(ENA.balanceOf(address(SAFE_ENA)), 0);
        assertEq(ENA.balanceOf(owner), ownerBefore + safeBalance);
    }
}
