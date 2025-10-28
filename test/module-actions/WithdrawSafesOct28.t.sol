// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test} from "forge-std/Test.sol";

import {WithdrawSafesOct28 as WithdrawSafes} from "../../script/module-actions/WithdrawSafesOct28.s.sol";
import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe} from "../../src/interfaces/external/ISafe.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {console2} from "forge-std/console2.sol";

contract WithdrawSafesTestOct28 is Test {
    uint256 constant BLOCK_NUMBER = 23676745;
    address constant ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ISafe constant SAFE_WETH = ISafe(0xBA8DceB5d0a59B80193173736180ec45fF7DBfc3);
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    WithdrawSafes script;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), BLOCK_NUMBER);
        script = new WithdrawSafes();
    }

    function testPlanMovesTokensToOwners() public {
        address ownerWeth = SAFE_WETH.getOwners()[0];

        uint256 safeWethBalance = WETH.balanceOf(address(SAFE_WETH));
        uint256 ownerWethBefore = WETH.balanceOf(ownerWeth);

        RumpelModule.Call[] memory calls = script.plan();
        console2.logBytes(bytes(abi.encode(calls)));

        vm.prank(ADMIN);
        MODULE.exec(calls);

        assertEq(WETH.balanceOf(address(SAFE_WETH)), 0);
        assertEq(WETH.balanceOf(ownerWeth), ownerWethBefore + safeWethBalance);
    }
}
