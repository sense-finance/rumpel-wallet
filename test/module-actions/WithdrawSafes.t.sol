// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity =0.8.24;

import {Test} from "forge-std/Test.sol";

import {WithdrawSafes} from "../../script/module-actions/WithdrawSafes.s.sol";
import {RumpelModule} from "../../src/RumpelModule.sol";
import {ISafe} from "../../src/interfaces/external/ISafe.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";

contract WithdrawSafesTest is Test {
    uint256 constant BLOCK_NUMBER = 23_535_805;
    address constant ADMIN = 0x9D89745fD63Af482ce93a9AdB8B0BbDbb98D3e06;

    RumpelModule constant MODULE = RumpelModule(0x28c3498B4956f4aD8d4549ACA8F66260975D361a);
    ISafe constant SAFE_WETH = ISafe(0x358b600115dB863F57591152010fb112F1EA6616);
    ISafe constant SAFE_ETHFI = ISafe(0xbBa9d6349d63E667d42Ef1F3c4D180917BF6124A);
    ERC20 constant WETH = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 constant ETHFI = ERC20(0xFe0c30065B384F05761f15d0CC899D4F9F9Cc0eB);

    WithdrawSafes script;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"), BLOCK_NUMBER);
        script = new WithdrawSafes();
    }

    function testPlanMovesTokensToOwners() public {
        address ownerWeth = SAFE_WETH.getOwners()[0];
        address ownerEthfi = SAFE_ETHFI.getOwners()[0];

        uint256 safeWethBalance = WETH.balanceOf(address(SAFE_WETH));
        uint256 safeEthfiBalance = ETHFI.balanceOf(address(SAFE_ETHFI));
        uint256 ownerWethBefore = WETH.balanceOf(ownerWeth);
        uint256 ownerEthfiBefore = ETHFI.balanceOf(ownerEthfi);

        RumpelModule.Call[] memory calls = script.plan();

        vm.prank(ADMIN);
        MODULE.exec(calls);

        assertEq(WETH.balanceOf(address(SAFE_WETH)), 0);
        assertEq(ETHFI.balanceOf(address(SAFE_ETHFI)), 0);

        assertEq(WETH.balanceOf(ownerWeth), ownerWethBefore + safeWethBalance);
        assertEq(ETHFI.balanceOf(ownerEthfi), ownerEthfiBefore + safeEthfiBalance);
    }
}
